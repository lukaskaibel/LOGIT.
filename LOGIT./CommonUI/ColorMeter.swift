//
//  ColorMeter.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.10.22.
//

import SwiftUI

struct ColorMeter: View {
    
    // MARK: - Parameters
    
    let items: [Item]
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            if items.isEmpty {
                Rectangle()
                    .foregroundColor(.secondaryLabel)
                    .frame(maxHeight: geometry.size.height)
            } else {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        Rectangle()
                            .foregroundColor(item.color)
                            .frame(maxHeight: geometry.size.height * CGFloat(item.amount)/CGFloat(overallAmount()))
                    }
                }
            }
        }.frame(width: 7)
            .clipShape(Capsule())
    }
    
    // MARK: - Supporting Methods
    
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
        ColorMeter(items: [ColorMeter.Item(color: .green, amount: 1),
                           ColorMeter.Item(color: .blue, amount: 2),
                           ColorMeter.Item(color: .red, amount: 3)])
    }
}
