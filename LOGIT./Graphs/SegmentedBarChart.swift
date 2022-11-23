//
//  TargetPerWeekGraph.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.03.22.
//

import SwiftUI

struct SegmentedBarChart: View {
    
    let items: [Item]
    let hLines: [HLine]
    @Binding var selectedItemIndex: Int
    
    var body: some View {
        VStack(spacing: 20) {
            GeometryReader { geometry in
                HStack(spacing: 20) {
                    ForEach(items) { item in
                        bar(for: item, chartHeight: geometry.size.height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItemIndex = items.firstIndex(of: item)!
                            }
                    }
                }.frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                .overlay {
                    ZStack {
                        ForEach(hLines) { line in
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(line.color)
                                    .overlay {
                                        Text(NSLocalizedString("target", comment: ""))
                                            .font(.footnote.weight(.medium))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .offset(x: 0, y: 12)
                                    }
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: (geometry.size.height / CGFloat(maxYValue)) * CGFloat(line.y) - 10)
                            }
                        }
                    }
                }
            }
            
            HStack {
                ForEach(items) { item in
                    Text(item.x)
                        .foregroundColor(selectedItemIndex == items.firstIndex(of: item)! ? .white : .secondaryLabel)
                        .font(.footnote.weight(selectedItemIndex == items.firstIndex(of: item)! ? .bold : .regular))
                        .padding(.vertical, 2)
                        .padding(.horizontal, 5)
                        .background(selectedItemIndex == items.firstIndex(of: item)! ? Color.accentColor : .clear)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity)
                }
            }.padding(.horizontal, 3)
             
        }
    }
    
    // MARK: - Supporting Views
    
    @ViewBuilder
    private func bar(for item: Item, chartHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 2) {
                if item.y == 0 {         // prevents columns from collapsing when y is 0
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: chartHeight / CGFloat(maxYValue) - 2)
                } else {
                    ForEach(0..<item.y, id:\.self) { _ in
                        Rectangle()
                            .frame(height: chartHeight / CGFloat(maxYValue) - 2)
                    }
                }
            }.frame(width: 25)
                .cornerRadius(5)
                .frame(maxWidth: .infinity)
        }.foregroundColor(item.barColor)
    }
    
    var maxYValue: Int {
        ((items.map{ $0.y }) + (hLines.map{ $0.y })).max() ?? 1
    }
    
    struct Item: Identifiable, Equatable {
        let x: String
        let y: Int
        let barColor: Color
        var id: UUID { UUID() }
    }
    
    struct HLine: Identifiable {
        let title: String
        let y: Int
        let color: Color
        var id: UUID { UUID() }
    }
    
}

/*
struct TargetPerWeekView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedBarChart(items: [("Jan", 0), ("Feb", 0), ("Mar", 6), ("Apr", 6), ("May", 2)]
                            .map { SegmentedBarChart.Item(x: $0.0,
                                                         y: $0.1,
                                                         barColor: $0.1 >= 3,
                                                         isSelected: $0.1 == "May") },
                          hLines: [SegmentedBarChart.HLine(title: "Target",
                                                           y: 3, color: .accentColor)])
            .frame(height: 200)
    }
}
*/
