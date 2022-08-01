//
//  ProgressInWeekView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.07.22.
//

import SwiftUI

struct ProgressInWeekView: View {
    
    let goal: Int
    let progress: Int
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .background {
                LinearGradient(colors: [.accentColor.opacity(0.5), .accentColor], startPoint: .leading, endPoint: .trailing)
            }
            .mask {
                HStack(spacing: 3) {
                    ForEach(0..<maxValue, id:\.self) { index in
                        Rectangle()
                            .foregroundColor(colorForRect(with: index))
                        
                    }
                }.frame(maxHeight: 8)
                    .clipShape(Capsule())
            }
        
    }
    
    private var maxValue: Int { max(goal, progress) }
    private func colorForRect(with index: Int) -> Color {
        guard goal > progress else { return .black }
        return index >= progress ? .separator : .gray
    }
    
}

struct ProgressInWeekView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressInWeekView(goal: 4, progress: 3)
            .padding()
    }
}
