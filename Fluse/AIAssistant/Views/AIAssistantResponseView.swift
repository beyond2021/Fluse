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
        case .visualizeExpenses(let chartType, let options):
            VisualizeExpenseLogView(text: response.text, options: options, chartType: chartType)
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
struct VisualizeExpenseLogView: View {
    let text: String
    let options: [Option]
    let chartType: ChartType
    // animation
    @State private var isAnimated: Bool = false
    @State private var trigger: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(.headline)
            if options.count > 0 {
                Divider()
                switch chartType {
                case .pie:
                    PieChartView(options: options)
                    #if os(macOS)
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .padding(.bottom)
                    #endif
                        .frame(maxWidth: .infinity)
//                        .frame(height: 400)
                        //.padding(.bottom)
                case .bar:
                    BarChartView(options: options)
                    #if os(macOS)
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .padding(.bottom)
                    #endif
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .padding()
                case .line:
                    LineChartView(options: options)
                    #if os(macOS)
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .padding(.bottom)
                    #endif
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    AIAssistantResponseView(response: .init(text: "Hello", type: .contentText))
}
