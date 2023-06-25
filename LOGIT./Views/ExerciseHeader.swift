//
//  ExerciseHeader.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 27.11.22.
//

import SwiftUI

struct ExerciseHeader: View {
    
    // MARK: - Parameters
    
    let exercise: Exercise?
    let secondaryExercise: Exercise?
    let exerciseAction: () -> Void
    let secondaryExerciseAction: (() -> Void)?
    let isSuperSet: Bool
    let navigationToDetailEnabled: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    if navigationToDetailEnabled {
                        exerciseAction()
                    }
                } label: {
                    HStack(spacing: 3) {
                        Text(exercise?.name ?? NSLocalizedString("noName", comment: ""))
                        if navigationToDetailEnabled {
                            NavigationChevron()
                                .foregroundColor(.secondaryLabel)
                        }
                    }
                }
            }
            if isSuperSet {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.body.weight(.medium))
                        .padding(.leading)
                    Button {
                        if navigationToDetailEnabled {
                            secondaryExerciseAction?()
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text(secondaryExercise?.name ?? "Select second exercise")
                            if navigationToDetailEnabled {
                                NavigationChevron()
                                    .foregroundColor(secondaryExercise == nil ? .placeholder : .secondaryLabel)
                            }
                        }
                    }
                    Spacer()
                }
                .foregroundColor(secondaryExercise == nil ? .placeholder : .label)
            }
        }
        .textCase(nil)
        .font(.title3.weight(.bold))
        .foregroundColor(.label)
        .lineLimit(1)
    }
}
