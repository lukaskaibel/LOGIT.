//
//  MuscleGroupSplitTile.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 13.08.24.
//

import SwiftUI

struct MuscleGroupSplitTile: View {
    
    @EnvironmentObject private var workoutRepository: WorkoutRepository
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(NSLocalizedString("muscleSplit", comment: ""))
                        .tileHeaderTertiaryStyle()
//                    Text(NSLocalizedString("lastTenWorkouts", comment: ""))
//                        .tileHeaderStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                NavigationChevron()
                    .foregroundColor(.secondaryLabel)
            }
            PieGraph(
                items:
                    getOverallMuscleGroupOccurances()
                    .map {
                        PieGraph.Item(
                            title: $0.0.description.capitalized,
                            amount: $0.1,
                            color: $0.0.color,
                            isSelected: false
                        )
                    },
                showZeroValuesInLegend: true,
                hideLegend: true
            )
            .frame(height: 180)
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }
    
    private var lastTenWorkouts: [Workout] {
        Array(workoutRepository.getWorkouts(sortedBy: .date).prefix(10))
    }

    private func getOverallMuscleGroupOccurances() -> [(MuscleGroup, Int)] {
        Array(
            lastTenWorkouts
                .reduce(
                    [:],
                    { current, workout in
                        current.merging(workout.muscleGroupOccurances, uniquingKeysWith: +)
                    }
                )
                .merging(allMuscleGroupZeroDict, uniquingKeysWith: +)
        )
        .sorted {
            MuscleGroup.allCases.firstIndex(of: $0.key)! < MuscleGroup.allCases.firstIndex(
                of: $1.key
            )!
        }
    }
}

private var allMuscleGroupZeroDict: [MuscleGroup: Int] {
    MuscleGroup.allCases.reduce(into: [MuscleGroup: Int](), { $0[$1, default: 0] = 0 })
}

#Preview {
    GeometryReader { geometry in
        MuscleGroupSplitTile()
            .previewEnvironmentObjects()
            .frame(width: geometry.size.width / 2)
    }
    .padding()
}
