//
//  FunctionsManager.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/15/24.
//  CAN BE USED FROM ANY VIEWMODEL

import Foundation
import FirebaseFirestore // access the db
import ChatGPTSwift // access the function calling ChatGPT API

class FunctionsManager {
    
    let api: ChatGPTAPI
    let db = DatabaseManager.shared
    var addLogConfirmationCallback: AddExpenseLogConfirmationCallback?
    
    // Fixing the date by telling ChatGPT the time.
    static let currentDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        return df
        
    }()
    // Custom JSON Decoder for MM-dd-yyy
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = FunctionsManager.currentDateFormatter.date(from: dateString) else {
                /// not able to decode
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date.")
            }
            return date
        })
        return jsonDecoder
    }()
    
    
    var systemText: String {
        "You are an expert of tracking and managing expense logs. Dont make assumptions about what values to plug into functions. Ask for clarification if a user request is ambiguous. Current date is \(Self.currentDateFormatter.string(from: .now))"
    }
    
    init(apiKey: String) {
        self.api = .init(apiKey: apiKey)
    }
    
    func prompt(_ prompt: String, model: ChatGPTModel = .gpt_hyphen_4o, messageID: UUID? = nil) async throws -> AIAssistantResponse {
        do {
            let message = try await api.callFunction(prompt: prompt, tools: tools, model: model, systemText: systemText)
            try Task.checkCancellation()
            
            if let toolCall = message.tool_calls?.first,
               let functionType = AIAssistantFunctionType(rawValue: toolCall.function.name),
               let argumentData = toolCall.function.arguments.data(using: .utf8) {
                switch functionType {
                case .addExpenseLog:
                    guard let addLogConfirmationCallback else {
                        throw "Add log confirmation callback is missing"
                    }
                    guard let addExpenseLogArgs = try? self.jsonDecoder.decode(AddExpenseLogArgs.self, from: argumentData) else {
                        throw "Failed to parse function arguments \(toolCall.function.name) \(toolCall.function.arguments)"
                    }
                    let log = ExpenseLog(id: UUID().uuidString, name: addExpenseLogArgs.title, category: addExpenseLogArgs.category, amount: addExpenseLogArgs.amount, currency: addExpenseLogArgs.currency ?? "USD", date: addExpenseLogArgs.date ?? .now)
                    
                    return .init(text: "Please select the confirm button before i add it to your expense list", type: .addExpenseLog(.init(log: log, messageID: messageID, userConfirmation: .pending, confirmationCallback: addLogConfirmationCallback)))
                    
                case .listExpensesLog:
                    guard let listExpenseArgs = try? self.jsonDecoder.decode(ListExpenseArgs.self, from: argumentData) else {
                        throw "Failed to parse function arguments \(toolCall.function.name) \(toolCall.function.arguments)"
                    }
                    
                    let query = getQuery(args: listExpenseArgs)
                    let docs = try await query.getDocuments()
                    let logs = try docs.documents.map { try $0.data(as: ExpenseLog.self)}
                    
                    let text: String
                    if listExpenseArgs.doesDateFilterExists {
                        if logs.isEmpty {
                            text = "You don't have any expenses at given date"
                        } else {
                            text = "Sure, here's the list of your expenses with total sum of \(Utils.numberFormatter.string(from: NSNumber(value: logs.reduce(0, { $0 + $1.amount }))) ?? "")"
                        }
                    } else {
                        if logs.isEmpty {
                            text = "You don't have any recent expenses"
                        } else {
                            text = "Sure, here's the list of your last \(logs.count) expenses with total sum of \(Utils.numberFormatter.string(from: NSNumber(value: logs.reduce(0, { $0 + $1.amount }))) ?? "")"
                        }
                    }
                    
                    return .init(text: text, type: .listExpenses(logs))
                case .visualizeExpenses:
                    guard let visualizeExpenseArgs = try? self.jsonDecoder.decode(VisualizeExpenseArgs.self, from: argumentData) else {
                        throw "Failed to parse function arguments \(toolCall.function.name) \(toolCall.function.arguments)"
                    }
                    
                    let query = getQuery(args: .init(date: visualizeExpenseArgs.date, startDate: visualizeExpenseArgs.startDate, endDate: visualizeExpenseArgs.endDate, category: nil, sortOrder: nil, quantityOfLogs: nil))
                    
                    let docs = try await query.getDocuments()
                    let logs = try docs.documents.map { try $0.data(as: ExpenseLog.self)}
                    
                    var categorySumDict = [Category: Double]()
                    logs.forEach { log in
                        categorySumDict.updateValue((categorySumDict[log.categoryEnum] ?? 0) + log.amount, forKey: log.categoryEnum)
                    }
                    
                    let chartOptions = categorySumDict.map { Option(category: $0.key, amount: $0.value) }
                    return .init(text: "Sure, here is the visualization of your expenses for each category", type: .visualizeExpenses(visualizeExpenseArgs.chartTypeEnum, chartOptions))
                
                    
                    
                default:
                    var text = "Function Name: \(toolCall.function.name)"
                    text += "\nArgs: \(toolCall.function.arguments)" //
                    return .init(text: text, type: .contentText)
                }
                
                
                /// if ChatGPT is avble to get all parameters  provided message.tool_calls?.first will be available to us.
                /// this will be used to get thr function name and all the parameters
                
//                messageRow.response = .customContent({ AIAssistantResponseView(text: text)}) // render
                
            } else if let message = message.content {
                /// If its not a function call, maybe a parameter is missing
                /// will be rendered as a regular message content. ChatGPT will prompt the user about the missing parameter
                api.appendToHistoryList(userText: prompt, responseText: message) // when user supplies missing parameter
                return .init(text: message, type: .contentText)
            } else {
                throw "Invalid Response" //
            }
            
        } catch {
            print(error.localizedDescription) // for debugging
            throw error
        }
        
    }
    //MARK: Firestore Query Helper for expenselogs stored on Firebase
    func getQuery(args: ListExpenseArgs) -> Query {
        var filters = [Filter]()
        // If the startdate  and end date exists
        if let startDate = args.startDate,
           let endDate = args.endDate {
            filters.append(.whereField("date", isGreaterOrEqualTo: startDate.startOfDay))
            filters.append(.whereField("date", isLessThanOrEqualTo: endDate.endOfDay))
        } else if let date = args.date {
            // if only date exists
            filters.append(.whereField("date", isGreaterOrEqualTo: date.startOfDay))
            filters.append(.whereField("date", isLessThanOrEqualTo: date.endOfDay))
            
        }
        // if we have a category
        if let category = args.category {
            filters.append(.whereField("category", isEqualTo: category))
        }
        var query = db.logsCollection.whereFilter(.andFilter(filters))
        let sortOrder = SortOrder(rawValue: args.sortOrder ?? "") ?? .descending
        query = query.order(by: "date", descending: sortOrder == .descending)
        
        if args.doesDateFilterExists {
            if let quantityOfLogs = args.quantityOfLogs {
                query = query.limit(to: quantityOfLogs)
            }
        } else {
            let quantityOfLogs = args.quantityOfLogs ?? 100
            query = query.limit(to: quantityOfLogs)
        }
        return query
    }
}
