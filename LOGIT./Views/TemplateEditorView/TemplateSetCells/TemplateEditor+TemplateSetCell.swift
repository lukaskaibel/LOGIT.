//
//  TemplateEditor+TemplateSetCell.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 29.11.22.
//

import SwiftUI


extension TemplateEditorView {
    
    @ViewBuilder
    internal func templateSetCell(templateSet: TemplateSet) -> some View {
        HStack {
            HStack {
                ColorMeter(items: [ColorMeter.Item(color: templateSet.setGroup?.exercise?.muscleGroup?.color.translucentBackground ?? .placeholder,
                                                   amount: 1)],
                           roundedEdges: templateSetIsFirst(templateSet: templateSet) && templateSetIsLast(templateSet: templateSet) ? .all :
                                            templateSetIsFirst(templateSet: templateSet) ? .top :
                                            templateSetIsLast(templateSet: templateSet) ? .bottom :
                                            .none)
                    .padding(.top, templateSetIsFirst(templateSet: templateSet) ? CELL_PADDING : 0)
                    .padding(.bottom, templateSetIsLast(templateSet: templateSet) ? CELL_PADDING : 0)
                Spacer()
                Text("\(templateSet.setGroup!.sets.firstIndex(of: templateSet)! + 1)")
                    .padding(.top, templateSetIsFirst(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, templateSetIsLast(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                Spacer()
            }
            .frame(maxWidth: 80)
            if let standardSet = templateSet as? TemplateStandardSet {
                TemplateStandardSetCell(for: standardSet)
                    .padding(.top, templateSetIsFirst(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, templateSetIsLast(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .frame(maxWidth: .infinity)
            } else if let dropSet = templateSet as? TemplateDropSet {
                TemplateDropSetCell(for: dropSet)
                    .padding(.top, templateSetIsFirst(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, templateSetIsLast(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .frame(maxWidth: .infinity)
            } else if let superSet = templateSet as? TemplateSuperSet {
                TemplateSuperSetCell(for: superSet)
                    .padding(.top, templateSetIsFirst(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .padding(.bottom, templateSetIsLast(templateSet: templateSet) ? CELL_PADDING : CELL_PADDING / 2)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, CELL_PADDING)
    }

    private func templateSetIsFirst(templateSet: TemplateSet) -> Bool {
        templateSet.setGroup!.sets.firstIndex(of: templateSet)! == 0
    }
    
    private func templateSetIsLast(templateSet: TemplateSet) -> Bool {
        templateSet.setGroup!.sets.firstIndex(of: templateSet)! == templateSet.setGroup!.sets.count - 1
    }
    
}
