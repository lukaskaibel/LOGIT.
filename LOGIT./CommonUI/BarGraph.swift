//
//  BarGraph.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.12.21.
//

import SwiftUI

struct BarGraph: View {
    
    let xValues: [String]?
    let yValues: [Int]
    let barColors: [Color]
    let hLineValue: Int?
    let hLineSymbol: Image?
    
    init(xValues: [String]? = nil, yValues: [Int], barColors: [Color]? = nil, hLineValue: Int? = nil, hLineSymbol: Image? = nil) {
        self.xValues = xValues
        self.yValues = yValues
        if let barColors = barColors {
            self.barColors = barColors
        } else {
            self.barColors = (0..<yValues.count).map { _ in Color.clear }
        }
        self.hLineValue = hLineValue
        self.hLineSymbol = hLineSymbol
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(yValues.indices, id:\.self) { i in
                                HStack(spacing: 0) {
                                    VerticalDivider
                                    VStack {
                                        Spacer(minLength: 0)
                                        Rectangle()
                                            .foregroundColor(barColors[i])
                                            .background(Color.secondaryLabel)
                                            .frame(height: CGFloat(yValues[i]) / CGFloat(maxValue) * geometry.size.height)
                                            .cornerRadius(5)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .background {
                                VStack(spacing: 0) {
                                    ForEach(0..<4) { _ in
                                        VStack {
                                            HorizontalDivider
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .overlay {
                                if let hLineValue = hLineValue {
                                    VStack(spacing: 0) {
                                        Spacer(minLength: 0)
                                        Rectangle()
                                            .foregroundColor(.accentColor)
                                            .frame(height: 1)
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(height: CGFloat(hLineValue+1) / CGFloat(maxValue) * geometry.size.height)
                                    }
                                } else { EmptyView() }
                            }
                        }
                    }
                    HorizontalDivider
                    if let xValues = xValues {
                        HStack {
                            ForEach(xValues, id:\.self) { value in
                                HStack(alignment: .bottom, spacing: 3) {
                                    VerticalDivider
                                    Text(value)
                                        .font(.footnote)
                                        .foregroundColor(.tertiaryLabel)
                                    Spacer(minLength: 0)
                                }
                            }
                        }.frame(height: 20)
                    }
                }
                VerticalDivider
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(String(maxValue))
                            .offset(x: 0, y: -10)
                        Spacer()
                        Text(String(0))
                            .offset(x: 0, y: 8)
                    }.overlay {
                        GeometryReader { geometry in
                            if let hLineSymbol = hLineSymbol, let hLineValue = hLineValue {
                                VStack(spacing: 0) {
                                    Spacer()
                                    hLineSymbol
                                        .foregroundColor(.accentColor)
                                        .offset(x: -2, y: 6)
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(height: CGFloat(hLineValue+1) / CGFloat(maxValue) * geometry.size.height)
                                }
                            }
                        }
                    }
                    if xValues != nil {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 1, height: 20)
                    }
                }.foregroundColor(.tertiaryLabel)
                    .font(.footnote)
                    .padding(.leading, 5)
            }
            
        }
    }
    
    var VerticalDivider: some View {
        Rectangle()
            .strokeBorder(style: StrokeStyle(lineWidth: 0.25, dash: [2]))
            .foregroundColor(.separator)
            .frame(width: 0.5)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    var HorizontalDivider: some View {
        Rectangle()
            .foregroundColor(.separator)
            .frame(height: 0.5)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    //MARK: Computed Properties
    
    private var maxValue: Int {
        ((yValues.max() ?? 1) / 4) * 4 + 4
    }
    
}

struct BarGraph2_Previews: PreviewProvider {
    static var previews: some View {
        BarGraph(xValues: ["Jan", "Feb", "Mar", "Apr", "May"], yValues: [3, 4, 6, 5, 2], hLineValue: 3, hLineSymbol: Image(systemName: "target"))
            .padding()
            .frame(height: 120)
    }
}
