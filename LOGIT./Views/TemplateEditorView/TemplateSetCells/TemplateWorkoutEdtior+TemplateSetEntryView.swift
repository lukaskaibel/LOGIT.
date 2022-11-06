//
//  TemplateSetEntryView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 20.05.22.
//

import SwiftUI

extension TemplateEditorView {
    
    // View with Textfields for entry of repetitions and weight
    internal struct TemplateSetEntryView: View {
        
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var templateWorkoutEditor: TemplateEditor
        
        @Binding var repetitions: Int64
        @Binding var weight: Int64
        var repetitionsPlaceholder: String?
        var weightPlaceholder: String?
        
        var body: some View {
            HStack {
                TextField("0", text: repetitionsString)
                    .keyboardType(.numberPad)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(7)
                    .background(colorScheme == .light ? Color.tertiaryFill : .background)
                    .cornerRadius(7)
                    .overlay {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(repetitions == 0 ? .secondaryLabel : .label)
                                .font(.caption.weight(.bold))
                                .padding(7)
                            Spacer()
                        }
                    }
                TextField("0", text: weightString)
                    .keyboardType(.numberPad)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(7)
                    .background(colorScheme == .light ? Color.tertiaryFill : .background)
                    .cornerRadius(7)
                    .overlay {
                        HStack {
                            Image(systemName: "scalemass")
                                .foregroundColor(weight == 0 ? .secondaryLabel : .label)
                                .font(.caption.weight(.bold))
                                .padding(7)
                            Spacer()
                        }
                    }
            }
        }
        
        var repetitionsString: Binding<String> {
            Binding<String>(
                get: { repetitions == 0 ? "" : String(repetitions) },
                set: { value in
                    repetitions = NumberFormatter().number(from: value)?.int64Value ?? 0
                    templateWorkoutEditor.updateView()
                }
            )
        }

        var weightString: Binding<String> {
            Binding<String>(
                get: { weight == 0 ? "" : String(convertWeightForDisplaying(weight)) },
                set: { value in
                    weight = convertWeightForStoring(NumberFormatter().number(from: value)?.int64Value ?? 0)
                    templateWorkoutEditor.updateView()
                }
            )
        }

    }
    
}
