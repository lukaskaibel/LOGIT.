//
//  TargetPerWeekGraph.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.03.22.
//

import SwiftUI

struct TargetPerWeekGraph: View {
    
    let xValues: [String]
    let yValues: [Int]
    let target: Int
    
    var body: some View {
        VStack(spacing: 20) {
            GeometryReader { geometry in
                HStack(spacing: 20) {
                    ForEach(yValues, id:\.self) { y in
                        VStack(spacing: 0) {
                            Spacer()
                            VStack(spacing: 2) {
                                if y == 0 {         // prevents columns from collapsing when y is 0
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(height: geometry.size.height / CGFloat(maxValue) - 2)
                                } else {
                                    ForEach(0..<y, id:\.self) { _ in
                                        Rectangle()
                                            .frame(height: geometry.size.height / CGFloat(maxValue) - 2)
                                    }
                                }
                            }.frame(width: 25)
                                .cornerRadius(5)
                                .frame(maxWidth: .infinity)
                        }.foregroundColor(y >= target ? .accentColor: .accentColor.opacity(0.4))
                    }
                }.frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                .background {
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.accentColor.opacity(0.4))
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: (geometry.size.height / CGFloat(maxValue)) * CGFloat(target) - 10)
                    }
                }
            }
            HStack(spacing: 20) {
                ForEach(xValues, id:\.self) { x in
                    Text(x)
                        .foregroundColor(xValues.last! == x ? .accentColor : .secondaryLabel)
                        .font(.footnote.weight(xValues.last! == x ? .semibold : .regular))
                        .frame(maxWidth: .infinity)
                }
            }.padding(.horizontal, 10)
        }
    }
    
    var maxValue: Int {
        (yValues + [target]).max() ?? 1
    }
    
}

struct TargetPerWeekView_Previews: PreviewProvider {
    static var previews: some View {
        TargetPerWeekGraph(xValues: ["Jan", "Feb", "Mar", "Apr", "May"], yValues: [0, 0, 6, 6, 2], target: 3)
            .frame(height: 200)
    }
}
