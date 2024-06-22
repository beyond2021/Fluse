//
//  ChartView.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 6/20/24.
//

import Charts
import SwiftUI
import Foundation

enum ChartType: String {
    case pie, bar
}

// For the Data
struct Option: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
}

struct BarChartView: View {
    let options: [Option]
    var body: some View {
        Chart {
            ForEach(options) {
                BarMark(x: .value("Category", $0.category.rawValue),
                        y: .value("Amount", $0.amount))
                .foregroundStyle(by: .value("Category", $0.category.rawValue))
            }
        }
        .chartForegroundStyleScale(mapping: { (category: String) in
            Category(rawValue: category)?.color ?? .accentColor
        })
        .padding(.vertical)
    }
}

struct PieChartView: View {
    let options: [Option]
    //
    @State private var isAnimated: Bool = false
    @State private var trigger: Bool = false

    var body: some View {
        Chart {
            ForEach(options) { option in
                SectorMark(
                    angle: .value("Amount", option.amount),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .cornerRadius(5)
                .foregroundStyle(by: .value("Category", option.category.rawValue))
            }
     
        }
        .chartYScale(domain: 0...12000)
        .frame(height: 250)
        .chartForegroundStyleScale(mapping: { (category: String) in
            Category(rawValue: category)?.color ?? .accentColor
        })
        .padding(.vertical)
    }
}

#Preview {
    Group {
        BarChartView(options: [.init( category: .food, amount: 300), .init(category: .entertainment, amount: 1000) ])
        PieChartView(options: [.init( category: .food, amount: 300), .init(category: .entertainment, amount: 1000) ])
    }
}
