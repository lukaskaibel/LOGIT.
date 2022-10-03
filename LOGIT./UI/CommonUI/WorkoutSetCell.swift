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
        HStack {
            Spacer()
            if let standardSet = workoutSet as? StandardSet {
                StandardSetCell(for: standardSet)
            } else if let dropSet = workoutSet as? DropSet {
                DropSetCell(for: dropSet)
            } else if let superSet = workoutSet as? SuperSet {
                SuperSetCell(for: superSet)
            }
        }
    }
    
    private func StandardSetCell(for standardSet: StandardSet) -> some View {
        WorkoutSetEntry(repetitions: Int(standardSet.repetitions), weight: Int(standardSet.weight))
    }
    
    private func DropSetCell(for dropSet: DropSet) -> some View {
        VStack(alignment: .trailing) {
            ForEach(0..<(dropSet.repetitions?.count ?? 0), id:\.self) { index in
                WorkoutSetEntry(repetitions: Int(dropSet.repetitions?.value(at: index) ?? 0),
                                weight: Int(dropSet.weights?.value(at: index) ?? 0))
            }
        }
    }
    
    private func SuperSetCell(for superSet: SuperSet) -> some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("1")
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                WorkoutSetEntry(repetitions: Int(superSet.repetitionsFirstExercise),
                                weight: Int(superSet.weightFirstExercise))
            }
            HStack {
                Text("2")
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                WorkoutSetEntry(repetitions: Int(superSet.repetitionsSecondExercise),
                                weight: Int(superSet.weightSecondExercise))
            }
        }
    }
    
    private func WorkoutSetEntry(repetitions: Int, weight: Int) -> some View {
        HStack(spacing: SetGroupDetailView.columnSpace) {
            Text(repetitions > 0 ? String(repetitions) : "")
                .font(.system(.body, design: .rounded, weight: .semibold))
                .frame(maxWidth: SetGroupDetailView.columnWidth)
            Text(weight > 0 ? String(convertWeightForDisplaying(weight)) : "")
                .font(.system(.body, design: .rounded, weight: .semibold))
                .frame(maxWidth: SetGroupDetailView.columnWidth)
        }.padding(.vertical, 5)
    }
            
    var dividerCircle: some View {
        Circle()
            .foregroundColor(.separator)
            .frame(width: 4, height: 4)
    }
    
}
