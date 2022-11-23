//
//  PieGraph.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.06.22.
//

import SwiftUI

struct PieGraph: View {
    
    enum Configuration {
        case normal, small
    }
    
    let items: [Item]
    let circleLineWidth: CGFloat
    let configuration: Configuration
    let showZeroValuesInLegend: Bool
    let hideLegend: Bool
    
    init(items: [Item], configuration: Configuration = .normal, showZeroValuesInLegend: Bool = false, hideLegend: Bool = false) {
        self.items = items.filter { showZeroValuesInLegend ? true : $0.amount > 0 }
        self.circleLineWidth = configuration == .small ? 10 : 15
        self.configuration = configuration
        self.showZeroValuesInLegend = showZeroValuesInLegend
        self.hideLegend = hideLegend
    }
    
    var body: some View {
        HStack {
            if configuration == .normal && !hideLegend {
                HStack {
                    Grid(verticalSpacing: 5) {
                        ForEach(0..<((items.count+1)/2), id:\.self) { index in
                            GridRow {
                                HStack {
                                    itemView(for: items[index*2])
                                    if items.indices.contains(index*2+1) {
                                        itemView(for: items[index*2+1])
                                    }
                                }
                            }
                        }
                        
                    }
                }
                Spacer()
            }
            ZStack {
                ForEach(items) { item in
                    Circle()
                        .trim(from: trimFrom(for: item), to: trimTo(for: item))
                        .stroke(lineWidth: circleLineWidth)
                        .rotation(Angle(degrees: -90))
                        .foregroundColor(item.color)
                }
            }.background {
                Circle()
                    .stroke(lineWidth: circleLineWidth)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            }
            .frame(minHeight: 100, alignment: .trailing)
                .padding(configuration == .small ? 5 : 15)
        }
    }
    
    @ViewBuilder
    private func itemView(for item: Item) -> some View {
        VStack(alignment: .leading) {
            Text(item.title)
            UnitView(value: "\(percentage(for: item))", unit: "%  (\(item.amount))")
                .foregroundColor(item.amount > 0 ? item.color : .secondaryLabel)
        }.frame(minWidth: 80, alignment: .leading)
    }
    
    private func percentage(for item: Item) -> Int {
        Int(round(Float(item.amount)/Float(items.map(\.amount).reduce(0, +))*100))
    }
        
    private func trimFrom(for item: Item) -> CGFloat {
        let summedAmounts = items.map(\.amount).reduce(0, +)
        return items
            .prefix(items.firstIndex { $0 == item } ?? 0)
            .map { CGFloat($0.amount) / CGFloat(summedAmounts) }
            .reduce(0, +)
    }
    
    private func trimTo(for item: Item) -> CGFloat {
        let summedAmounts = items.map(\.amount).reduce(0, +)
        return items
            .prefix((items.firstIndex { $0 == item } ?? 0) + 1)
            .map { CGFloat($0.amount) / CGFloat(summedAmounts) }
            .reduce(0, +)
    }
    
    struct Item: Equatable, Identifiable {
        let id = UUID()
        let title: String
        let amount: Int
        let color: Color
    }
}

struct PieGraph_Previews: PreviewProvider {
    static var previews: some View {
            PieGraph(items: [PieGraph.Item(title: "Chest", amount: 4, color: .blue),
                             PieGraph.Item(title: "Back", amount: 3, color: .green),
                             PieGraph.Item(title: "Arms", amount: 4, color: .yellow),
                             PieGraph.Item(title: "Shoulders", amount: 2, color: .purple),
                             PieGraph.Item(title: "Abs", amount: 1, color: .cyan),
                             PieGraph.Item(title: "Legs", amount: 2, color: .red)
                            ], configuration: .small)
            .frame(height: 40)
            .tileStyle()
            .padding()
    }
}
