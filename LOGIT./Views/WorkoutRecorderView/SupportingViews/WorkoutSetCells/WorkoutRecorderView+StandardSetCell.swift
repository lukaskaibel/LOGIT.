//
//  WorkoutRecorderView+StandardSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal struct StandardSetCell: View {
        
        // MARK: - Environment
        
        @Environment(\.setWorkoutEndDate) var setWorkoutEndDate: (Date) -> Void
        @Environment(\.workoutSetTemplateSetDictionary) var workoutSetTemplateSetDictionary: [WorkoutSet:TemplateSet]
        @EnvironmentObject var database: Database
        
        // MARK: - Parameters
        
        @ObservedObject var standardSet: StandardSet
        let indexInWorkout: Int
        @Binding var focusedIntegerFieldIndex: IntegerField.Index?
        
        // MARK: - Body
        
        var body: some View {
            HStack {
                IntegerField(
                    placeholder: repetitionsPlaceholder(for: standardSet),
                    value: standardSet.repetitions,
                    setValue: {
                        standardSet.repetitions = $0
                        setWorkoutEndDate(.now)
                    },
                    maxDigits: 4,
                    index: IntegerField.Index(
                        primary: indexInWorkout,
                        secondary: 0,
                        tertiary: 0
                    ),
                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                )
                IntegerField(
                    placeholder: weightPlaceholder(for: standardSet),
                    value: Int64(convertWeightForDisplaying(standardSet.weight)),
                    setValue: {
                        standardSet.weight = convertWeightForStoring($0)
                        setWorkoutEndDate(.now)
                    },
                    maxDigits: 4,
                    index: IntegerField.Index(
                        primary: indexInWorkout,
                        secondary: 0,
                        tertiary: 1
                    ),
                    focusedIntegerFieldIndex: $focusedIntegerFieldIndex
                )
            }
        }
        
        // MARK: - Supporting Methods
        
        private func repetitionsPlaceholder(for standardSet: StandardSet) -> Int64 {
            guard let templateStandardSet = workoutSetTemplateSetDictionary[standardSet] as? TemplateStandardSet else { return 0 }
            return templateStandardSet.repetitions
        }
        
        private func weightPlaceholder(for standardSet: StandardSet) -> Int64 {
            guard let templateStandardSet = workoutSetTemplateSetDictionary[standardSet] as? TemplateStandardSet else { return 0 }
            return Int64(convertWeightForDisplaying(templateStandardSet.weight))
        }
        
    }
    
}
