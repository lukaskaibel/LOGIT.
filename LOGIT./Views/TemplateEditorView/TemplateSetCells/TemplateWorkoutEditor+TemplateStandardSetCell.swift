//
//  TemplateWorkoutEditor+TemplateStandardSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 20.05.22.
//

import SwiftUI

extension TemplateEditorView {
    
    internal func TemplateStandardSetCell(for templateStandardSet: TemplateStandardSet) -> some View {
        TemplateSetEntryView(repetitions: Binding(get: { templateStandardSet.repetitions },
                                                      set: { templateStandardSet.repetitions = $0 }),
                                 weight: Binding(get: { templateStandardSet.weight },
                                                 set: { templateStandardSet.weight = $0 }))
    }
    
}
