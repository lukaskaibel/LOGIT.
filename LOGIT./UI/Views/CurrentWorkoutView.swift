//
//  CurrentWorkoutView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.03.24.
//

import SwiftUI

struct CurrentWorkoutView: View {
    
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Current Workout")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Group {
                    if let workoutStartTime = workout.date {
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
            Text(workoutHasName ? workout.name! : Workout.getStandardName(for: .now))
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var workoutHasName: Bool {
        !(workout.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
}

// MARK: - Preview

private struct PreviewWrapper: View {
    
    @EnvironmentObject var database: Database
    
    var body: some View {
        CurrentWorkoutView(workout: database.testWorkout)
            .previewEnvironmentObjects()
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
    }
    
}

#Preview {
    PreviewWrapper()
        .previewEnvironmentObjects()
}
