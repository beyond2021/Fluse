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
    case pie, bar, line
}

// For the Data
struct Option: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
    /// Animatable Property
    var isAnimated: Bool = false
}

struct BarChartView: View {
    let options: [Option]
    // animation
    @State private var isAnimated: Bool = false
    @State private var trigger: Bool = false
    var body: some View {
        Chart {
            ForEach(options) {
                BarMark(
                    x: .value("Category", $0.category.rawValue),
                    y: .value("Amount", isAnimated ? $0.amount : 0)
                )
                .cornerRadius(5)
                .foregroundStyle(by: .value("Category", $0.category.rawValue))
                
                
            }
        }
        .onTapGesture {
            if options.count > 0 {
                trigger.toggle()
            }
        }
//        .chartYScale(domain: 0...12000)
        .frame(height: 350)
        .chartForegroundStyleScale(mapping: { (category: String) in
            Category(rawValue: category)?.color ?? .accentColor
        })
        .padding(.vertical)
        .padding(.vertical)
        .onAppear(perform: animateChart)
        .onDisappear(perform: resetChartAnimation)
        .onChange(of: trigger, initial: false) { oldValue, newValue in
            resetChartAnimation()
            animateChart()
        }
    }
    // MARK: Animating Chart
    private func animateChart() {
        guard !isAnimated else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.smooth) {
                isAnimated = true
            }
        }
    }
     private func resetChartAnimation() {
         isAnimated = false
     }
}

struct PieChartView: View {
    var options: [Option]
    //
    @State private var isAnimated: Bool = false
    @State private var trigger: Bool = false

    var body: some View {
        Chart {
            ForEach(options) { option in
                SectorMark(
                    angle: .value("Amount", isAnimated ? option.amount : 0),
                    innerRadius: .fixed(61),
                    angularInset: 1
                )
                .cornerRadius(5)
                .foregroundStyle(by: .value("Category", option.category.rawValue))
            }
        }
        .onTapGesture {
            if options.count > 0 {
                trigger.toggle()
            }
        }
        .chartYScale(domain: 0...12000)
        .frame(height: 450)// height
        .chartForegroundStyleScale(mapping: { (category: String) in
            Category(rawValue: category)?.color ?? .accentColor
        })
        .padding()
        .onAppear(perform: animateChart)
        .onDisappear(perform: resetChartAnimation)
        .onChange(of: trigger, initial: false) { oldValue, newValue in
            resetChartAnimation()
            animateChart()
        }
    }
    // MARK: Animating Chart
    private func animateChart() {
        guard !isAnimated else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.smooth) {
                isAnimated = true
            }
        }
    }
     private func resetChartAnimation() {
         isAnimated = false
     }
}

struct LineChartView: View {
    var options: [Option]
    //
    @State private var isAnimated: Bool = false
    @State private var trigger: Bool = false

    var body: some View {
        Chart {
            ForEach(options) { option in
                LineMark(
                    x: .value("Category", option.category.rawValue),
                    y: .value("Downloads", isAnimated ? option.amount : 0)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.green.gradient)
                .symbol {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                }
                .opacity(isAnimated ? 1 : 0)
            }
        }
        .onTapGesture {
            if options.count > 0 {
                trigger.toggle()
            }
        }
//        .chartYScale(domain: 0...12000)
//        .frame(height: 350)
        .chartForegroundStyleScale(mapping: { (category: String) in
            Category(rawValue: category)?.color ?? .accentColor
        })
        .padding(.vertical)
        .onAppear(perform: animateChart)
        .onDisappear(perform: resetChartAnimation)
        .onChange(of: trigger, initial: false) { oldValue, newValue in
            resetChartAnimation()
            animateChart()
        }
    }
    // MARK: Animating Chart
    private func animateChart() {
        guard !isAnimated else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.smooth) {
                isAnimated = true
            }
        }
    }
     private func resetChartAnimation() {
         isAnimated = false
     }
}

#Preview {
    Group {
        BarChartView(options: [.init( category: .food, amount: 300), .init(category: .entertainment, amount: 1000) ])
        PieChartView(options: [.init( category: .food, amount: 300), .init(category: .entertainment, amount: 1000) ])
        LineChartView(options: [.init( category: .food, amount: 300), .init(category: .entertainment, amount: 1000) ])
    }
}
