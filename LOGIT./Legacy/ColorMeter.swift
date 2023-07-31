//
//  ColorMeter.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.10.22.
//

import SwiftUI

struct ColorMeter: View {

    enum Edges {
        case top, bottom, all, none
    }

    enum SplitStyle {
        case horizontal, vertical
    }

    // MARK: - Parameters

    let items: [Item]
    let splitStyle: SplitStyle
    let roundedEdges: Edges

    init(items: [Item], splitStyle: SplitStyle = .vertical, roundedEdges: Edges = .all) {
        self.items = items
        self.roundedEdges = roundedEdges
        self.splitStyle = splitStyle
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            if items.isEmpty {
                Rectangle()
                    .foregroundStyle(Color.secondaryLabel)
                    .frame(maxHeight: geometry.size.height)
            } else {
                if splitStyle == .horizontal {
                    HStack(spacing: 0) {
                        ForEach(items) { item in
                            Rectangle()
                                .foregroundStyle(item.color)
                                .frame(
                                    width: geometry.size.width * CGFloat(item.amount)
                                        / CGFloat(overallAmount())
                                )
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            Rectangle()
                                .foregroundStyle(item.color)
                                .frame(
                                    maxHeight: geometry.size.height * CGFloat(item.amount)
                                        / CGFloat(overallAmount())
                                )
                        }
                    }
                }
            }
        }
        .frame(width: 7)
        //        .cornerRadius(3.5, corners: roundedEdges == .top ? [.topLeft, .topRight] :
        //                        roundedEdges == .bottom ? [.bottomLeft, .bottomRight] :
        //                        roundedEdges == .all ? [.allCorners] :
        //                        [])
    }

    // MARK: - Computed Properties

    private func overallAmount() -> Int {
        items.reduce(0, { $0 + $1.amount })
    }

    // MARK: - Item

    struct Item: Identifiable {
        let color: Color
        let amount: Int
        var id: UUID { UUID() }
    }

}

struct ColorMeter_Previews: PreviewProvider {
    static var previews: some View {
        ColorMeter(
            items: [
                ColorMeter.Item(color: .green, amount: 1),
                ColorMeter.Item(color: .blue, amount: 1),
                ColorMeter.Item(color: .red, amount: 0),
            ],
            splitStyle: .horizontal
        )
    }
}
