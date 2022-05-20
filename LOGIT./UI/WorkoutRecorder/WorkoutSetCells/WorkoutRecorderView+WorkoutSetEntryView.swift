//
//  WorkoutRecorderView+WorkoutSetEntryView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 13.05.22.
//

import SwiftUI

extension WorkoutRecorderView {
    
    // View with Textfields for entry of repetitions and weight
    internal struct WorkoutSetEntryView: View {
        
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var workoutRecorder: WorkoutRecorder
        
        @Binding var repetitions: Int64
        @Binding var weight: Int64
        var repetitionsPlaceholder: String?
        var weightPlaceholder: String?
        
        var body: some View {
            HStack {
                TextField(repetitionsPlaceholder ?? "0", text: repetitionsString)
                    .keyboardType(.numberPad)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(7)
                    .background(repetitions == 0 ? (colorScheme == .light ? Color.tertiaryFill : .background) : .accentColorBackground)
                    .cornerRadius(5)
                    .overlay {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(repetitions == 0 ? .secondaryLabel : .accentColor)
                                .font(.caption.weight(.bold))
                                .padding(7)
                            Spacer()
                        }
                    }
                TextField(weightPlaceholder ?? "0", text: weightString)
                    .keyboardType(.numberPad)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.trailing)
                    .padding(7)
                    .background(weight == 0 ? (colorScheme == .light ? Color.tertiaryFill : .background) : .accentColorBackground)
                    .cornerRadius(5)
                    .overlay {
                        HStack {
                            Image(systemName: "scalemass")
                                .foregroundColor(weight == 0 ? .secondaryLabel : .accentColor)
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
                    workoutRecorder.updateView()
                }
            )
        }

        var weightString: Binding<String> {
            Binding<String>(
                get: { weight == 0 ? "" : String(convertWeightForDisplaying(weight)) },
                set: { value in
                    weight = convertWeightForStoring(NumberFormatter().number(from: value)?.int64Value ?? 0)
                    workoutRecorder.updateView()
                }
            )
        }

    }

}
