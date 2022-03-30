//
//  LineGraph.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.03.22.
//

import SwiftUI

struct LineGraph: View {
    
    let xValues: [String]?
    let yValues: [Int]
    
    @Binding var selectedIndex: Int?
    
    init(xValues: [String]? = nil, yValues: [Int], selectedIndex: Binding<Int?> = .constant(nil)) {
        self.xValues = xValues
        self.yValues = yValues
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            GeometryReader { outerGeometry in
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0,
                                              y: (1 - yValues[0].cgFloat / maxYValue.cgFloat) * geometry.size.height))
                        (1..<yValues.count).forEach { index in
                            path.addLine(to: CGPoint(x: (index.cgFloat / (yValues.count - 1).cgFloat) * geometry.size.width,
                                                  y: (1 - yValues[index].cgFloat / maxYValue.cgFloat) * geometry.size.height))
                        }
                    }.stroke(Color.accentColor.opacity(0.5), lineWidth: 5)
                        .overlay {
                            ZStack {
                                ForEach(0..<yValues.count, id:\.self) { index in
                                    Circle()
                                        .stroke(lineWidth: 3)
                                        .foregroundColor(.accentColor)
                                        .frame(width: index == selectedIndex ? 15 : 10, height: index == selectedIndex ? 15 : 10)
                                        .background(Color.background)
                                        .offset(x: -geometry.size.width/2, y: -geometry.size.height/2)
                                        .offset(x: (index.cgFloat / (yValues.count - 1).cgFloat) * geometry.size.width,
                                                y: (1 - yValues[index].cgFloat / maxYValue.cgFloat) * geometry.size.height)
                                        .animation(.interactiveSpring(), value: 1.0)
                                }
                            }
                        }
                }.padding()
                    .padding(.top)
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                Text(String(maxYValue))
                                    .foregroundColor(.accentColor)
                                    .font(.footnote.weight(.semibold))
                                    .padding(5)
                                Spacer()
                            }

                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                let oldIndex = selectedIndex
                                if drag.location.x > 5 {
                                    let newIndex = Int( drag.location.x / outerGeometry.size.width * yValues.count.cgFloat)
                                    if yValues.indices.contains(newIndex) {
                                        selectedIndex = newIndex
                                        if oldIndex != selectedIndex {
                                            UISelectionFeedbackGenerator().selectionChanged()
                                        }
                                    }
                                }
                            }
                            .onEnded { _ in
                                selectedIndex = nil
                            }
                    )
            }
            Divider()
            if let xValues = xValues {
                HStack {
                    ForEach(xValues.indices, id:\.self) { index in
                        Text(xValues[index])
                            .foregroundColor(.secondaryLabel)
                            .font(.footnote)
                        if index < xValues.count - 1 {
                            Spacer()
                        }
                    }
                }.padding(.top, 10)
                    .padding(.horizontal, 5)
            }
        }
        
    }
    
    private var maxYValue: Int {
        (yValues.max() ?? 0) + 1
    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        LineGraph(xValues: ["Mon", "Tue", "Wed", "Thr", "Fri"], yValues: [30, 45, 50, 30, 60])
            .frame(height: 180)
            .tileStyle()
            .padding()
    }
}
