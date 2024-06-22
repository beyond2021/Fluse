//
//  FunctionResponse.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/15/24.
//

import Foundation

typealias AddExpenseLogConfirmationCallback = ((Bool, AddExpenseLogViewProperties) -> Void)

// States of the confirmation flow
enum UserConfiemation {
    case pending, confirmed, cancelled
}
// passing the data to the type
struct AddExpenseLogViewProperties {
    let log: ExpenseLog
    let messageID: UUID?
    let userConfirmation: UserConfiemation
    let confirmationCallback: AddExpenseLogConfirmationCallback?
}

struct AIAssistantResponse {
    let text: String
    let type: AIAssistantResponseFunctionType
}


enum AIAssistantResponseFunctionType {
    //use this to render the view
    case addExpenseLog(AddExpenseLogViewProperties)
    // to render the string eq missing parameters
    case listExpenses([ExpenseLog]) // 
    case visualizeExpenses(ChartType, [Option])
    case contentText
}
