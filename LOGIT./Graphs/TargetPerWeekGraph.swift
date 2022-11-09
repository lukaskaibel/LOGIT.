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
                    ForEach(yValues.indices, id:\.self) { index in
                        VStack(spacing: 0) {
                            Spacer()
                            VStack(spacing: 2) {
                                if yValues[index] == 0 {         // prevents columns from collapsing when y is 0
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(height: geometry.size.height / CGFloat(maxValue) - 2)
                                } else {
                                    ForEach(0..<yValues[index], id:\.self) { _ in
                                        Rectangle()
                                            .frame(height: geometry.size.height / CGFloat(maxValue) - 2)
                                    }
                                }
                            }.frame(width: 25)
                                .cornerRadius(5)
                                .frame(maxWidth: .infinity)
                        }.foregroundColor(yValues[index] >= target ? .accentColor: .accentColor.opacity(0.4))
                    }
                }.frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                .overlay {
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.accentColor.opacity(0.4))
                            .overlay {
                                Text(NSLocalizedString("target", comment: ""))
                                    .font(.footnote.weight(.medium))
                                    .foregroundColor(.accentColor.opacity(0.4))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(x: 0, y: 12)
                            }
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: (geometry.size.height / CGFloat(maxValue)) * CGFloat(target) - 10)
                    }
                }
            }
            HStack(spacing: 20) {
                ForEach(xValues.indices, id:\.self) { index in
                    Text(xValues[index])
                        .foregroundColor(xValues.last! == xValues[index] ? .accentColor : .secondaryLabel)
                        .font(.footnote.weight(xValues.last! == xValues[index] ? .semibold : .regular))
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
