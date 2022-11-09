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
        
        // MARK: - Environment
        
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var database: Database
        
        // MARK: - Parameters
        
        @Binding var repetitions: Int64
        @Binding var weight: Int64
        var repetitionsPlaceholder: String?
        var weightPlaceholder: String?
        
        // MARK: - Body
        
        var body: some View {
            HStack {
                TextField("0", text: repetitionsString)
                    .keyboardType(.numberPad)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(10)
                    .background(repetitions == 0 ? (colorScheme == .light ? Color.tertiaryFill : .background) : .accentColor.translucentBackground)
                    .cornerRadius(5)
                    .overlay {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(repetitions == 0 ? .secondaryLabel : .accentColor)
                                .font(.caption.weight(.bold))
                                .padding(10)
                            Spacer()
                        }
                    }
                TextField("0", text: weightString)
                    .keyboardType(.numberPad)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(10)
                    .background(weight == 0 ? (colorScheme == .light ? Color.tertiaryFill : .background) : .accentColor.translucentBackground)
                    .cornerRadius(5)
                    .overlay {
                        HStack {
                            Image(systemName: "scalemass")
                                .foregroundColor(weight == 0 ? .secondaryLabel : .accentColor)
                                .font(.caption.weight(.bold))
                                .padding(10)
                            Spacer()
                        }
                    }
            }
        }
        
        // MARK: - Supporting Methods
        
        var repetitionsString: Binding<String> {
            Binding<String>(
                get: { repetitions == 0 ? "" : String(repetitions) },
                set: { value in
                    repetitions = NumberFormatter().number(from: value)?.int64Value ?? 0
                    database.refreshObjects()
                }
            )
        }

        var weightString: Binding<String> {
            Binding<String>(
                get: { weight == 0 ? "" : String(convertWeightForDisplaying(weight)) },
                set: { value in
                    weight = convertWeightForStoring(NumberFormatter().number(from: value)?.int64Value ?? 0)
                    database.refreshObjects()
                }
            )
        }

    }
    
}
