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
                .font(.system(.body, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(10)
                .background(
                    ZStack {
                        Color.background
                        repetitions == 0 ? Color.fill : .accentColor.secondaryTranslucentBackground
                    }
                )
                .cornerRadius(5)
            TextField(weightPlaceholder ?? "0", text: weightString)
                .keyboardType(.numberPad)
                .foregroundColor(.accentColor)
                .font(.system(.body, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(10)
                .background(
                    ZStack {
                        Color.background
                        weight == 0 ? Color.fill : .accentColor.secondaryTranslucentBackground
                    }
                )
                .cornerRadius(5)
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
