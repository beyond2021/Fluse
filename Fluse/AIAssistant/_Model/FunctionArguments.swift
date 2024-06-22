//
//  FunctionArguments.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/15/24.
// Decoding the response from ChatGPT

import Foundation

struct AddExpenseLogArgs: Codable {
    let title: String
    let amount: Double
    let category: String
    let currency: String?
    let date: Date?
}

//MARK: Ai asisitant response and type

struct ListExpenseArgs: Codable {
    let date: Date?
    let startDate: Date?
    let endDate: Date?
    let category: String?
    let sortOrder: String?
    let quantityOfLogs: Int?
    
    var doesDateFilterExists: Bool {
        (startDate != nil && endDate != nil) || date != nil // means datefilter exists
    }
}

struct VisualizeExpenseArgs: Codable {
    let date: Date?
    let startDate: Date?
    let endDate: Date?
    
    let chartType: String
    var chartTypeEnum: ChartType {
        ChartType(rawValue: chartType) ?? .pie
    }
}

