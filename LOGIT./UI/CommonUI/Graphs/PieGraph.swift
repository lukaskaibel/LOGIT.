//
//  PieGraph.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.06.22.
//

import SwiftUI

struct PieGraph: View {
    
    let items: [Item]
    private let circleLineWidth: CGFloat = 15
    
    var body: some View {
        HStack {
            ZStack {
                ForEach(items) { item in
                    Circle()
                        .trim(from: trimFrom(for: item), to: trimTo(for: item))
                        .stroke(lineWidth: 15)
                        .rotation(Angle(degrees: -90))
                        .foregroundColor(item.color)
                }
            }.background {
                Circle()
                    .stroke(lineWidth: circleLineWidth)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
            }
            VStack(alignment: .leading) {
                ForEach(items) { item in
                    HStack {
                        Text(String(item.amount))
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(item.color)
                            .clipShape(Circle())
                        Text(item.title)
                    }
                }
            }.frame(maxWidth: .infinity)
        }
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
        VStack {
            Text("Workouts per Muscle-Group")
                .frame(maxWidth: .infinity, alignment: .leading)
                .sectionHeaderStyle()
            PieGraph(items: [PieGraph.Item(title: "Chest", amount: 4, color: .blue),
                             PieGraph.Item(title: "Back", amount: 3, color: .green),
                             PieGraph.Item(title: "Arms", amount: 4, color: .yellow),
                             PieGraph.Item(title: "Shoulders", amount: 2, color: .purple),
                             PieGraph.Item(title: "Abdominals", amount: 1, color: .cyan),
                             PieGraph.Item(title: "Legs", amount: 2, color: .red)
                            ])
            .frame(maxHeight: 200)

        }
        .tileStyle()
    }
}
