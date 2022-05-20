//
//  WorkoutSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 14.05.22.
//

import SwiftUI

struct WorkoutSetCell: View {
    
    @ObservedObject var workoutSet: WorkoutSet
    
    var body: some View {
        if let standardSet = workoutSet as? StandardSet {
            StandardSetCell(for: standardSet)
        } else if let dropSet = workoutSet as? DropSet {
            DropSetCell(for: dropSet)
        }
    }
    
    private func StandardSetCell(for standardSet: StandardSet) -> some View {
        WorkoutSetEntry(repetitions: Int(standardSet.repetitions), weight: Int(standardSet.weight))
    }
    
    private func DropSetCell(for dropSet: DropSet) -> some View {
        VStack {
            ForEach(0..<(dropSet.repetitions?.count ?? 0), id:\.self) { index in
                WorkoutSetEntry(repetitions: Int(dropSet.repetitions?.value(at: index) ?? 0),
                                weight: Int(dropSet.weights?.value(at: index) ?? 0))
            }
        }
    }
    
    private func WorkoutSetEntry(repetitions: Int, weight: Int) -> some View {
        HStack {
            if repetitions > 0 {
                UnitView(value: String(repetitions), unit: "RPS")
            }
            if weight > 0 {
                if repetitions > 0 {
                    dividerCircle
                        .padding(.horizontal, 8)
                }
                UnitView(value: String(convertWeightForDisplaying(weight)), unit: WeightUnit.used.rawValue.uppercased())
            } else {
                UnitView(value: "", unit: "") //needed in order for cell not to collapse if reps and weight = 0
            }
        }.padding(.vertical, 5)
    }
            
    var dividerCircle: some View {
        Circle()
            .foregroundColor(.separator)
            .frame(width: 4, height: 4)
    }
    
}
