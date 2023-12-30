//
//  SegmentedStackedBarChart.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 23.11.23.
//

import Charts
import SwiftUI

struct SegmentedStackedBarChartItem<Identifier: Hashable>: Identifiable, Equatable {
    let id: Identifier
    let value: Int
    let color: Color
    
    static func == (lhs: SegmentedStackedBarChartItem<Identifier>, rhs: SegmentedStackedBarChartItem<Identifier>) -> Bool {
        lhs.id == rhs.id
    }
}

struct SegmentedStackedBarChartSegment<Identifier: Hashable>: Identifiable, Equatable {
    var id: Identifier { items.first!.id }
    let items: [SegmentedStackedBarChartItem<Identifier>]
    
    static func == (lhs: SegmentedStackedBarChartSegment<Identifier>, rhs: SegmentedStackedBarChartSegment<Identifier>) -> Bool {
        lhs.id == rhs.id
    }
}

struct SegmentedStackedBarChartCategory<Identifier: Hashable>: Identifiable, Equatable {
    var id: String { label }
    let label: String
    let segments: [SegmentedStackedBarChartSegment<Identifier>]
    
    static func == (lhs: SegmentedStackedBarChartCategory<Identifier>, rhs: SegmentedStackedBarChartCategory<Identifier>) -> Bool {
        lhs.id == rhs.id
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct SegmentedStackedBarChart<Identifier: Hashable>: View {
        
    // MARK: - Constants
    
    private let segmentSpacing: Float = 0.06
    private let standardBarWidth: MarkDimension = .init(integerLiteral: 20)
    
    // MARK: - State
    
    @Binding var selectedCategoryIndex: Int?
    let canSelectCategory: Bool
    let grayOutNotSelectedCategories: Bool
    
    // MARK: - Paramters
    
    let categories: [SegmentedStackedBarChartCategory<Identifier>]
    let horizontalRuleMarkValue: Int
    
    // MARK: - Body
    
    var body: some View {
        Chart {
            RuleMark(y: .value("Target", Float(horizontalRuleMarkValue) - segmentSpacing * 2))
                .foregroundStyle(Color.secondary)
                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, dash: [5, 15]))
//                .annotation(position: .leading, alignment: .leading) {
//                    Image(systemName: "target")
//                        .font(.title3.weight(.medium))
//                        .foregroundStyle(Color.secondary)
//                }
            ForEach(categories) { category in
                if category.segments.isEmpty {
                    BarMark(x: .value("Bar x value", category.label), y: .value("Placeholder", 1), width:  standardBarWidth)
                        .foregroundStyle(Color.clear)
                }
                ForEach(category.segments) { segment in

                    Group {
                        ForEach(segment.items) { item in
                            BarMark(
                                x: .value("Bar x value", category.label),
                                yStart: .value("Item y start", yStart(for: item, in: segment, in: category)),
                                yEnd: .value("Item y end", yEnd(for: item, in: segment, in: category)),
                                width:  standardBarWidth
                            )
                            .foregroundStyle(barColor(for: item, in: category))
                            .clipShape(RoundedCorner(radius: 5, corners: (segment.items.first == item ? [.bottomLeft, .bottomRight] : []) + (segment.items.last == item ? [.topLeft, .topRight] : [])))
                        }
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) { value in
                if let label = value.as(String.self) {
                    AxisValueLabel(label)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(
                            (selectedCategory?.label ?? "") == label
                                ? Color.primary : Color.secondary
                        )
                }
            }
        }
        .chartYAxis(.hidden)
        .overlay {
            if canSelectCategory {
                HStack {
                    ForEach(categories) { category in
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                TapGesture().onEnded { _ in
                                    if category != selectedCategory && !category.segments.isEmpty {
                                        UISelectionFeedbackGenerator().selectionChanged()
                                        selectedCategoryIndex = categories.firstIndex(of: category)
                                    }
                                }
                            )
                    }
                }
            }
        }
        .animation(.none)
    }
    
    // MARK: - Private Methods
    
    private func yStart(
        for item: SegmentedStackedBarChartItem<Identifier>,
        in segment: SegmentedStackedBarChartSegment<Identifier>,
        in category: SegmentedStackedBarChartCategory<Identifier>
    ) -> Float {
        let percentageBeforeItem: Float = Float(segment.items.prefix(while: { $0.id != item.id }).reduce(0, { $0 + $1.value })) / Float(segment.items.reduce(0, { $0 + $1.value }))
        return (Float(category.segments.firstIndex(of: segment)!) + segmentSpacing / 2) + (1 - segmentSpacing) * percentageBeforeItem
    }
    
    private func yEnd(
        for item: SegmentedStackedBarChartItem<Identifier>,
        in segment: SegmentedStackedBarChartSegment<Identifier>,
        in category: SegmentedStackedBarChartCategory<Identifier>
    ) -> Float {

        let overallValueOfSegment = Float(segment.items.reduce(0, { $0 + $1.value }))
        let percentageBeforeItem: Float = Float(segment.items.prefix(while: { $0.id != item.id }).reduce(0, { $0 + $1.value })) / overallValueOfSegment
        let percentageWithItem = percentageBeforeItem + Float(item.value) / overallValueOfSegment
        return Float(category.segments.firstIndex(of: segment)!) + segmentSpacing / 2 + (1 - segmentSpacing) * percentageWithItem
    }
    
    private var selectedCategory: SegmentedStackedBarChartCategory<Identifier>? {
        guard let index = selectedCategoryIndex else { return nil }
        return categories.value(at: index)
    }
    
    private func barColor(
        for item: SegmentedStackedBarChartItem<Identifier>,
        in category: SegmentedStackedBarChartCategory<Identifier>
    ) -> Color {
        guard grayOutNotSelectedCategories else { return item.color }
        return selectedCategory == nil || selectedCategory == category ? item.color : .gray
    }
    
}

#Preview {
    let chart = SegmentedStackedBarChart(
        selectedCategoryIndex: .constant(nil), canSelectCategory: false, grayOutNotSelectedCategories: true,
        categories: [
            .init(
                label: "Monday",
                segments: [
                    .init(
                        items: [
                            .init(id: 1, value: 1, color: .green),
                            .init(id: 2, value: 2, color: .blue),
                            .init(id: 3, value: 1, color: .red)
                        ]
                    ),
                    .init(
                        items: [
                            .init(id: 4, value: 1, color: .green),
                            .init(id: 5, value: 2, color: .blue),
                            .init(id: 6, value: 4, color: .red)
                        ]
                    )
                ]
            ),
            .init(
                label: "Tuesday",
                segments: [
                    .init(
                        items: [
                            .init(id: 1, value: 1, color: .green),
                            .init(id: 20, value: 6, color: .blue),
                            .init(id: 30, value: 3, color: .red)
                        ]
                    ),
                    .init(
                        items: [
                            .init(id: 40, value: 9, color: .green),
                            .init(id: 50, value: 2, color: .blue),
                            .init(id: 60, value: 0, color: .red)
                        ]
                    ),
                    .init(
                        items: [
                            .init(id: 70, value: 1, color: .green),
                            .init(id: 80, value: 2, color: .blue),
                            .init(id: 90, value: 3, color: .red)
                        ]
                    )
                ]
            ),
            .init(
                label: "Wednesday",
                segments: [
                    .init(
                        items: [
                            .init(id: 1, value: 1, color: .green),
                            .init(id: 2, value: 2, color: .blue),
                            .init(id: 3, value: 1, color: .red)
                        ]
                    ),
                    .init(
                        items: [
                            .init(id: 4, value: 1, color: .green),
                            .init(id: 5, value: 2, color: .blue),
                            .init(id: 6, value: 4, color: .red)
                        ]
                    )
                ]
            ),
            .init(
                label: "Thursday",
                segments: [
                    .init(
                        items: [
                            .init(id: 1, value: 1, color: .green),
                            .init(id: 20, value: 6, color: .blue),
                            .init(id: 30, value: 3, color: .red)
                        ]
                    ),
                    .init(
                        items: [
                            .init(id: 40, value: 9, color: .green),
                            .init(id: 50, value: 2, color: .blue),
                            .init(id: 60, value: 0, color: .red)
                        ]
                    ),
                    .init(
                        items: [
                            .init(id: 70, value: 1, color: .green),
                            .init(id: 80, value: 2, color: .blue),
                            .init(id: 90, value: 3, color: .red)
                        ]
                    )
                ]
            ),
            .init(
                label: "Friday",
                segments: [
                    .init(
                        items: [
                            .init(id: 1, value: 1, color: .green),
                            .init(id: 2, value: 2, color: .blue),
                            .init(id: 3, value: 1, color: .red)
                        ]
                    ),
                    .init(
                        items: [
                            .init(id: 4, value: 1, color: .green),
                            .init(id: 5, value: 2, color: .blue),
                            .init(id: 6, value: 4, color: .red)
                        ]
                    )
                ]
            )
        ],
        horizontalRuleMarkValue: 3
    )
    .frame(maxHeight: 250)
    
    return VStack {
        chart
        Spacer()
        chart
            .frame(height: 200)
            .padding(CELL_PADDING)
            .tileStyle()
            .padding()
    }
}
