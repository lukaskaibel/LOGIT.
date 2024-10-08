//
//  CurrentWorkoutView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.03.24.
//

import SwiftUI

struct CurrentWorkoutView: View {
    
    let workoutName: String?
    let workoutDate: Date?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(NSLocalizedString("currentWorkout", comment: ""))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Group {
                    if let workoutStartTime = workoutDate {
                        StopwatchView(startTime: workoutStartTime)
                    } else {
                        Text("-:--:--")
                    }
                }
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
                // TODO: If timer is running, add a Divider and the timer with a timer symbol
                // Maybe put a white rounded rect around the timer value, so its more visible
            }
            Text(workoutHasName ? workoutName! : Workout.getStandardName(for: workoutDate ?? .now))
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .padding(10)
        .floatingStyle()
    }
    
    private var workoutHasName: Bool {
        !(workoutName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
}

// MARK: - Preview

private struct PreviewWrapper: View {
    
    @EnvironmentObject var database: Database
    
    var body: some View {
        CurrentWorkoutView(workoutName: database.testWorkout.name, workoutDate: database.testWorkout.date)
            .previewEnvironmentObjects()
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
    }
    
}

#Preview {
    PreviewWrapper()
        .previewEnvironmentObjects()
}
