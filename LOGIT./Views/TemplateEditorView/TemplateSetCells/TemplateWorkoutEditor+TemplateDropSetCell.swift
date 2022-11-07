//
//  TemplateEditor+TemplateDropSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 20.05.22.
//

import SwiftUI

extension TemplateEditorView {
    
    internal func TemplateDropSetCell(for templateDropSet: TemplateDropSet) -> some View {
        VStack {
            ForEach(0..<(templateDropSet.repetitions?.count ?? 0), id:\.self) { index in
                TemplateSetEntryView(repetitions: Binding(get: { templateDropSet.repetitions?.value(at: index) ?? 0 },
                                                         set: { templateDropSet.repetitions?.replaceValue(at: index, with: $0) }),
                                    weight: Binding(get: { templateDropSet.weights?.value(at: index) ?? 0 },
                                                    set: { templateDropSet.weights?.replaceValue(at: index, with: $0) }))
            }
            Stepper("Drop count",
                    onIncrement: { templateEditor.addDrop(to: templateDropSet) },
                    onDecrement: { templateEditor.removeLastDrop(from: templateDropSet) })
        }
    }
    
}