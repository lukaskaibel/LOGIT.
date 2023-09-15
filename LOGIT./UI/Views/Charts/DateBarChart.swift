//
//  DateBarChart.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 14.09.23.
//

import Charts
import SwiftUI

struct DateBarChart: View {
    
    struct Item: Identifiable {
        var id: String { "\(date)\(value)" }
        let date: Date
        let value: Int
    }
    
    // MARK: - Constants
    
    private let yValuePaddingRatio = 0.1
    
    // MARK: - Properties
    
    let dateUnit: Calendar.Component
    let items: [Item]
    
    init(dateUnit: Calendar.Component, items: () -> [Item]) {
        self.dateUnit = dateUnit
        self.items = items()
    }
    
    // MARK: - Body
    
    var body: some View {
        Chart {
            ForEach(items) { item in
                BarMark(
                    x: .value("Date", item.date, unit: dateUnit),
                    y: .value("Value", item.value),
                    width: 20
                )
                .annotation(position: .top) {
                    Text(String(item.value))
                        .font(.footnote)
                }
                .clipShape(Capsule())
            }
        }
        .chartXAxis {
            AxisMarks(preset: .extended, values: .stride(by: dateUnit)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel(dateDescription(for: date))
                        .font(.caption.weight(.bold))
                }
            }
        }
        .chartXScale(domain: [minXValue, (Calendar.current.date(byAdding: .day, value: 7, to: .now)?.startOfWeek)!])
        .chartYAxis(.hidden)
    }
    
    // MARK: - Computed Properties
    
    private var minXValue: Date {
        return Calendar.current.date(
            byAdding: dateUnit,
            value: -8,
            to: .now
        )!
    }
    
    private var maxYValue: Int {
        (items.map { $0.value }.max() ?? 1) + yValuePadding
    }
    
    private var yValuePadding: Int {
        Int(ceil(Double(items.map { $0.value }.max() ?? 1) * yValuePaddingRatio))
    }
    
    private func dateDescription(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateUnit == .day ? "DDD" : dateUnit == .weekOfYear ? "d.M." : dateUnit == .month ? "MMM" : "MMM YY"
        return formatter.string(from: date).uppercased()
    }
    
}

struct DateBarChart_Previews: PreviewProvider {
    static var previews: some View {
        DateBarChart(dateUnit: .weekOfYear) {
            (1...11).map {
                .init(
                    date: Date().addingTimeInterval(-7882880 + 788288 * Double($0)),
                    value: Int.random(in: 0...100)
                )
            }
        }
        .frame(height: 250)
    }
}
