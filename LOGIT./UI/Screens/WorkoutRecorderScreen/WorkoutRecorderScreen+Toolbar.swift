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
                withAnimation {
                    isShowingChronoView.toggle()
                }
            } label: {
                if !isShowingChronoView && chronograph.status != .idle {
                    TimeStringView
                } else {
                    Image(systemName: chronograph.mode == .timer ? "timer" : "stopwatch")
                }
            }
            .buttonStyle(SelectionButtonStyle(isSelected: isShowingChronoView))
            Spacer()
            Text(
                "\(workout.setGroups.count) \(NSLocalizedString("exercise\(workout.setGroups.count == 1 ? "" : "s")", comment: ""))"
            )
            .font(.caption)
            Spacer()
        }
    }

    internal var ToolbarItemsKeyboard: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            if !isFocusingTitleTextfield {
                if let workoutSet = selectedWorkoutSet {
                    if let templateSet = workoutSetTemplateSetDictionary[workoutSet], templateSet.hasEntry {
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
