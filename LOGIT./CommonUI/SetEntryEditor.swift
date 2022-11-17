//
//  SetEntryView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 09.11.22.
//

import SwiftUI

struct SetEntryEditor: View {
    
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
            TextField(repetitionsPlaceholder ?? "0", text: repetitionsString)
                .keyboardType(.numberPad)
                .foregroundColor(.accentColor)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(10)
                .background(repetitions == 0 ? (colorScheme == .light ? Color.tertiaryFill : .background) : .accentColor.secondaryTranslucentBackground)
                .cornerRadius(5)
                .overlay {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(repetitions == 0 ? .placeholder : .accentColor)
                            .font(.caption.weight(.bold))
                            .padding(10)
                        Spacer()
                    }
                }
            TextField(weightPlaceholder ?? "0", text: weightString)
                .keyboardType(.numberPad)
                .foregroundColor(.accentColor)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(10)
                .background(weight == 0 ? (colorScheme == .light ? Color.tertiaryFill : .background) : .accentColor.secondaryTranslucentBackground)
                .cornerRadius(5)
                .overlay {
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(weight == 0 ? .placeholder : .accentColor)
                            .font(.caption.weight(.bold))
                            .padding(10)
                        Spacer()
                    }
                }
        }
    }
    
    // MARK: - Computed Properties
    
    var repetitionsString: Binding<String> {
        Binding<String>(
            get: { repetitions == 0 ? "" : String(repetitions) },
            set: { value in
                if Int(value) ?? 10000 < 10000 || value == "" {
                    repetitions = NumberFormatter().number(from: value)?.int64Value ?? 0
                    database.refreshObjects()
                }
            }
        )
    }

    var weightString: Binding<String> {
        Binding<String>(
            get: { weight == 0 ? "" : String(convertWeightForDisplaying(weight)) },
            set: { value in
                if Int(value) ?? 10000 < 10000 {
                    weight = convertWeightForStoring(NumberFormatter().number(from: value)?.int64Value ?? 0)
                    database.refreshObjects()
                }
            }
        )
    }

}

struct SetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        SetEntryEditor(repetitions: .constant(12), weight: .constant(80))
    }
}
