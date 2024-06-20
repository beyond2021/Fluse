//
//  AIAssistantResponseView.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/14/24.
//

import SwiftUI

struct AIAssistantResponseView: View {
    
    let response: AIAssistantResponse
    var body: some View {
        switch response.type {
        case .addExpenseLog(let props):
            AddExpenseLogView(props: props)
        case .listExpenses(let logs):
            ListExpensesLogsView(text: response.text, logs: logs)
        default:
            Text(response.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
}
struct AddExpenseLogView: View {
    let props: AddExpenseLogViewProperties
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please select the comfirm button before i add it the the expens list.")
            Divider()
            LogItemView(log: props.log)
            Divider()
            switch props.userConfirmation {
            case .pending:
                if let confirmationCallback = props.confirmationCallback {
                    HStack {
                        Button("Confirm") {
                            confirmationCallback(true, props)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        Button("Cancel", role: .destructive) {
                            confirmationCallback(false, props)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .tint(.red)
                    }
                }
            case .confirmed:
                Button("Confirmed") {}
                .buttonStyle(BorderedProminentButtonStyle())
                .disabled(true)
                Text("Sure, Ive added this log to your expense list ✅.")
            case .cancelled:
                Button("Cancel", role: .destructive) {}
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(.red)
                .disabled(true)
                Text("OK, I would not be adding this log ❌")
                
            }
        }
    }
}
struct ListExpensesLogsView: View {
    let text: String
    let logs: [ExpenseLog]
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
            if logs.count > 0 {
                Divider()
                ForEach(logs) {
                    LogItemView(log: $0)
                    Divider()
                }
            }
        }
    }
}

#Preview {
    AIAssistantResponseView(response: .init(text: "Hello", type: .contentText))
}
