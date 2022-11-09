//
//  VerticalMuscleGroupIndicator.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.10.22.
//

import SwiftUI

struct VerticalMuscleGroupIndicator: View {
    
    let muscleGroupAmounts: [(MuscleGroup, Int)]
    
    var body: some View {
        GeometryReader { geometry in
            if muscleGroupAmounts.reduce(0, { $0 + $1.1 }) == 0 {
                Rectangle()
                    .foregroundColor(.secondaryLabel)
                    .frame(maxHeight: geometry.size.height)
            } else {
                VStack(spacing: 0) {
                    ForEach(muscleGroupAmounts, id:\.self.0.rawValue) { muscleGroupAmount in
                        Rectangle()
                            .foregroundColor(muscleGroupAmount.0.color)
                            .frame(maxHeight: geometry.size.height * CGFloat(muscleGroupAmount.1)/CGFloat(muscleGroupAmounts.reduce(0, { $0 + $1.1 })))
                    }
                }
            }
        }.frame(width: 7)
            .clipShape(Capsule())

    }
}

struct VerticalMuscleGroupIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VerticalMuscleGroupIndicator(muscleGroupAmounts: [(.chest, 3), (.legs, 5), (.shoulders, 1)])
    }
}
