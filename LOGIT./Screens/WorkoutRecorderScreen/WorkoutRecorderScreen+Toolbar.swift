//
//  WorkoutRecorderView+Toolbar.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 14.06.23.
//

import SwiftUI

extension WorkoutRecorderScreen {

    internal var ToolbarItemsBottomBar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation {
                    isShowingChronoView.toggle()
                }
            } label: {
                if !isShowingChronoView && chronograph.status != .idle {
                    TimeStringView
                } else {
                    Image(systemName: "timer")
                        .selectionButtonStyle(isSelected: isShowingChronoView)
                }
            }
            Spacer()
            Text(
                "\(workout.setGroups.count) \(NSLocalizedString("exercise\(workout.setGroups.count == 1 ? "" : "s")", comment: ""))"
            )
            .font(.caption)
            Spacer()
            Button { isEditing.toggle() } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .selectionButtonStyle(isSelected: isEditing)
            }
            .disabled(workout.numberOfSetGroups == 0)
        }
    }

    internal var ToolbarItemsKeyboard: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            if !isFocusingTitleTextfield {
                if let workoutSet = selectedWorkoutSet {
                    if let _ = workoutSetTemplateSetDictionary[workoutSet] {
                        Button {
                            toggleSetCompleted(for: workoutSet)
                        } label: {
                            Image(systemName: "\(workoutSet.hasEntry ? "xmark" : "checkmark")")
                                .keyboardToolbarButtonStyle()
                        }
                    } else {
                        Button {
                            toggleCopyPrevious(for: workoutSet)
                        } label: {
                            Image(systemName: "\(workoutSet.hasEntry ? "xmark" : "return.right")")
                                .foregroundColor(
                                    !(workoutSet.previousSetInSetGroup?.hasEntry ?? false)
                                        && !workoutSet.hasEntry
                                        ? Color.placeholder : .primary
                                )
                                .keyboardToolbarButtonStyle()
                        }
                        .disabled(
                            !(workoutSet.previousSetInSetGroup?.hasEntry ?? false)
                                && !workoutSet.hasEntry
                        )
                    }
                }
                HStack(spacing: 0) {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        focusedIntegerFieldIndex = previousIntegerFieldIndex()
                    } label: {
                        Image(systemName: "chevron.up")
                            .foregroundColor(
                                previousIntegerFieldIndex() == nil ? Color.placeholder : .label
                            )
                            .keyboardToolbarButtonStyle()
                    }
                    .disabled(previousIntegerFieldIndex() == nil)
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        focusedIntegerFieldIndex = nextIntegerFieldIndex()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(
                                nextIntegerFieldIndex() == nil ? Color.placeholder : .label
                            )
                            .keyboardToolbarButtonStyle()
                    }
                    .disabled(nextIntegerFieldIndex() == nil)
                }
            }
            Button {
                if isFocusingTitleTextfield {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isFocusingTitleTextfield = false
                    }
                } else {
                    focusedIntegerFieldIndex = nil
                }
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .keyboardToolbarButtonStyle()
            }
            if !isFocusingTitleTextfield {
                Spacer()
            }
        }
    }

}
