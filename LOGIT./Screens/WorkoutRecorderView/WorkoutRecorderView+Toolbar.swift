//
//  WorkoutRecorderView+Toolbar.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 14.06.23.
//

import SwiftUI

extension WorkoutRecorderView {
    
    internal var ToolbarItemsBottomBar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation {
                    isShowingTimerView.toggle()
                }
            } label: {
                if !isShowingTimerView && (timer.isRunning || timer.isPaused) {
                    TimeStringView
                } else {
                    Image(systemName: "timer")
                        .foregroundColor(isShowingTimerView ? .white : .accentColor)
                        .padding(3)
                        .background(isShowingTimerView ? Color.accentColor.opacity(0.9) : .clear)
                        .cornerRadius(8)
                }
            }
            Spacer()
            Text("\(workout.setGroups.count) \(NSLocalizedString("exercise\(workout.setGroups.count == 1 ? "" : "s")", comment: ""))")
                .font(.caption)
            Spacer()
            Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("edit", comment: "")) {
                isEditing.toggle()
                editMode = isEditing ? .active : .inactive
            }.disabled(workout.numberOfSetGroups == 0)
        }
    }
    
    internal var ToolbarItemsKeyboard: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
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
                            .foregroundColor(!(workoutSet.previousSetInSetGroup?.hasEntry ?? false) && !workoutSet.hasEntry ? Color.placeholder : .primary)
                            .keyboardToolbarButtonStyle()
                    }
                    .disabled(!(workoutSet.previousSetInSetGroup?.hasEntry ?? false) && !workoutSet.hasEntry)
                }
            }
            HStack(spacing: 0) {
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    focusedIntegerFieldIndex = previousIntegerFieldIndex()
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(previousIntegerFieldIndex() == nil ? Color.placeholder : .label)
                        .keyboardToolbarButtonStyle()
                }
                .disabled(previousIntegerFieldIndex() == nil)
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    focusedIntegerFieldIndex = nextIntegerFieldIndex()
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(nextIntegerFieldIndex() == nil ? Color.placeholder : .label)
                        .keyboardToolbarButtonStyle()
                }
                .disabled(nextIntegerFieldIndex() == nil)
            }
            Button {
                focusedIntegerFieldIndex = nil
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .keyboardToolbarButtonStyle()
            }
            Spacer()
        }
    }
    
}
