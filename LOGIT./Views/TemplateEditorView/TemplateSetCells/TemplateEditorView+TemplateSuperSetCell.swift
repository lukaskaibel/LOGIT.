//
//  TemplateEditorView+TemplateSuperSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.05.22.
//

import SwiftUI

extension TemplateEditorView {
    
    internal func TemplateSuperSetCell(for templateSuperSet: TemplateSuperSet) -> some View {
        VStack {
            HStack {
                Text("1")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                SetEntryEditor(repetitions: Binding(get: { templateSuperSet.repetitionsFirstExercise },
                                                          set: { templateSuperSet.repetitionsFirstExercise = $0 }),
                                     weight: Binding(get: { templateSuperSet.weightFirstExercise },
                                                     set: { templateSuperSet.weightFirstExercise = $0 }))
            }
            HStack {
                Text("2")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                SetEntryEditor(repetitions: Binding(get: { templateSuperSet.repetitionsSecondExercise },
                                                          set: { templateSuperSet.repetitionsSecondExercise = $0 }),
                                     weight: Binding(get: { templateSuperSet.weightSecondExercise },
                                                     set: { templateSuperSet.weightSecondExercise = $0 }))
            }.accentColor(templateSuperSet.secondaryExercise?.muscleGroup?.color)
        }
    }
    
}
