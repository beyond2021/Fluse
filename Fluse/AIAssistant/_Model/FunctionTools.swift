//
//  FunctionTools.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/14/24.
//

import ChatGPTSwift // provides the methods to call functions. User openAPI generator
import Foundation

enum AIAssistantFunctionType: String {
    case addExpenseLog
    case listExpensesLog
    // Photo receipt snap TODO
    // Financial Health log TODO
    // Category Bugeting log TODO - grocery dining travel and more limits
    // Approahing Limit Log Notification to keep you on track and avoid over spending
}

//Refactor
typealias PropKeyValue = (key: String, value: [String: Any])

let titleProp = (key: "title",
                 value: [
                    "type": "string",
                    "description": "title or description of the expense"
                 ])

let amountProp = (key: "amount",
                  value: [
                    "type": "number",
                    "description": "cost or amount of the expense"
                  ])

let currencyProp = (key: "currency",
                    value: [
                        "type": "string",
                        "description": "Currency of the amount or cost. If you're not sure, just use USD as default value, no need to confirm with user"
                    ])
                    
let dateProp = (key: "date",
                value: [
                    "type": "string",
                    "description": "date of expense. always use this format as the response MM-dd-yyyy. if no year is provided just use current year"
                ])
                
let categoryProp = (key: "category",
                    value: [
                        "type": "string",
                        "enum": Category.allCases.map { $0.rawValue },
                        "description": "The category of the expense, if it's not provided explicitly by the user, you should infer it automatically based on the title of expense."
                    ])

// List Expense Props
let startDateProp = (key: "startDate",
                     value: [
                        "type": "string",
                        "description": "start date. always use this format as the response MM-dd-yyyy. If no year is provided, just use current year"
                     ]) // expenses during time range


let endDateProp = (key: "endDate",
                   value: [
                    "type": "string",
                    "description": "end date. always use this format as the response MM-dd-yyyy. if no year is provided just use current year"
                   ]) // expenses during time range
                   
 let sortOrderProp = (key: "sortOrder",
                     value: [
                        "type": "string",
                        "enum": ["ascending", "descending"],
                        "description": "the sort order of the list. if not provided, use descending as default value"
                     ]) // sort order

let quantityOfLogsProp = (key: "quantityOfLogs",
                          value: [
                            "type": "number",
                            "description": "Number of logs to be listed"
                          ]) // list my last 10 expenses


let chartTypeProp = (key: "chartType",
                     value: [
                        "type": "string",
                        "enum": ["pie", "bar"],
                        "description": "the type of chart to be shown. if not provided, use pie as default value."
                     ])
                     

//Methods to create a function
func createParameters(properties: [PropKeyValue], requiredProperties: [PropKeyValue]? = nil) -> Components.Schemas.FunctionParameters {
    var propDict = [String: [String: Any]]()
    properties.forEach {
        propDict[$0.key] = $0.value //Assign the key to the value
    }
    return try! .init(additionalProperties: .init(unvalidatedValue: [
        "type": "object",
        "properties": propDict,
        "required": requiredProperties?.compactMap{$0.key} ?? []
    ]))
}
//MARK: Define a function
func createFunction(name: String, description: String, properties: [PropKeyValue], requiredProperties: [PropKeyValue]? = nil) -> ChatCompletionTool {
    .init(_type: .function, function: .init(
        description: description,
        name: name,
        parameters: createParameters(properties: properties, requiredProperties: requiredProperties)))
}

let tools: [Components.Schemas.ChatCompletionTool] = [
    createFunction(name: AIAssistantFunctionType.addExpenseLog.rawValue,
                   description: "Add expense log",
                   properties: [titleProp,
                                amountProp,
                                currencyProp,
                                categoryProp,
                                dateProp ],
                   requiredProperties: [titleProp, amountProp, categoryProp ]),
    
    createFunction(name: AIAssistantFunctionType.listExpensesLog.rawValue,
                   description: "List expenses logs",
                   properties: [categoryProp,
                                dateProp,
                                startDateProp,
                                endDateProp,
                                sortOrderProp,
                                quantityOfLogsProp])
]

/*
 let tools: [Components.Schemas.ChatCompletionTool] = [.init(_type: .function, function:
 .init(description: "Add expense log",
 name: "addExpenseLog",
 parameters: try! .init(additionalProperties: .init(unvalidatedValue: [
 "type": "object",
 "properties": [
 "title": [
 "type": "string",
 "description": "title or description of the expense"
 ],
 "amount": [
 "type": "number",
 "description": "cost or amount of the expense"
 ],
 "currency": [
 "type": "string",
 "description": "Currency of the amount or cost. If you're not sure, just use USD as default value, no need to confirm with user"
 ],
 "category": [
 "type": "string",
 "enum": Category.allCases.map{ $0.rawValue},
 "description": "The category of the expense, if its not provided explicitly by the user, you should infer it automatically based on the title of the expense.",
 ],
 "date": [
 "type": "string",
 "description": "Date of expense. Always use this format as the response MM-dd-yyyy. If no year is provided just use current year."
 
 ]
 
 ],
 "required": ["title", "amount", "category"],
 
 ]))))
 ]
 */
