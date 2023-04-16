//
//  WorkoutRecorderView+DropSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal struct DropSetCell: View {
        
        // MARK: - Environment
        
        @Environment(\.setWorkoutEndDate) var setWorkoutEndDate: (Date) -> Void
        @Environment(\.workoutSetTemplateSetDictionary) var workoutSetTemplateSetDictionary: [WorkoutSet:TemplateSet]
        @EnvironmentObject var database: Database
        
        // MARK: - Parameters
        
        @ObservedObject var dropSet: DropSet
        let indexInWorkout: Int
        @Binding var focusedIntegerFieldIndex: IntegerField.Index?
        
        // MARK: - Body
        
        var body: some View {
            VStack {
                ForEach(0..<(dropSet.repetitions?.count ?? 0), id:\.self) { index in
                    HStack {
                        IntegerField(
                            placeholder: repetitionsPlaceholder(for: dropSet).value(at: index) ?? 0,
                            value: dropSet.repetitions?.value(at: index) ?? 0,
                            setValue: { dropSet.repetitions?.replaceValue(at: index, with: $0); setWorkoutEndDate(.now) },
                            maxDigits: 4,
                            index: IntegerField.Index(
                                primary: indexInWorkout,
                                secondary: index,
                                tertiary: 0
                            ),
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                        IntegerField(
                            placeholder: weightsPlaceholder(for: dropSet).value(at: index) ?? 0,
                            value: Int64(convertWeightForDisplaying(dropSet.weights?.value(at: index) ?? 0)),
                            setValue: { dropSet.weights?.replaceValue(at: index, with: $0); setWorkoutEndDate(.now) },
                            maxDigits: 4,
                            index: IntegerField.Index(
                                primary: indexInWorkout,
                                secondary: index,
                                tertiary: 1
                            ),
                            focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                        )
                    }
                }
                Stepper(
                    NSLocalizedString("dropCount", comment: ""),
                    onIncrement: { dropSet.addDrop(); database.refreshObjects() },
                    onDecrement: { dropSet.removeLastDrop(); database.refreshObjects() }
                )
                .accentColor(dropSet.exercise?.muscleGroup?.color)
            }
        }
        
        // MARK: - Supporting Methods
        
        private func repetitionsPlaceholder(for dropSet: DropSet) -> [Int64] {
            guard let templateDropSet = workoutSetTemplateSetDictionary[dropSet] as? TemplateDropSet else { return [0] }
            return templateDropSet.repetitions?.map { $0 } ?? .emptyList
        }
        
        private func weightsPlaceholder(for dropSet: DropSet) -> [Int64] {
            guard let templateDropSet = workoutSetTemplateSetDictionary[dropSet] as? TemplateDropSet else { return [0] }
            return templateDropSet.weights?.map { Int64(convertWeightForDisplaying($0)) } ?? .emptyList
        }
        
    }

}
