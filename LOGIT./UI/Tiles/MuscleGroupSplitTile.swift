//
//  MuscleGroupSplitTile.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 24.08.24.
//

import Charts
import SwiftUI

struct MuscleGroupSplitTile: View {
    
    @EnvironmentObject private var workoutRepository: WorkoutRepository
    
    var body: some View {
        if #available(iOS 17.0, *) {
            let muscleGroupOccurances = getOverallMuscleGroupOccurances()
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("muscleGroupSplit", comment: ""))
                            .tileHeaderStyle()
                        Text(NSLocalizedString("lastTenWorkouts", comment: ""))
                            .tileHeaderSecondaryStyle()
                    }
                    Spacer()
                    NavigationChevron()
                        .foregroundStyle(.secondary)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Focused on")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let firstMuscleGroup = muscleGroupOccurances.first?.0 {
                            HStack {
                                ForEach(getFocusedMuscleGroups()) { muscleGroup in
                                    Text(muscleGroup.description)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(muscleGroup.color)
                                }
                            }
                        }
                    }
                    Spacer()
                    Chart {
                        ForEach(muscleGroupOccurances, id:\.0) { muscleGroupOccurance in
                            SectorMark(
                                angle: .value("Value", muscleGroupOccurance.1),
                                innerRadius: .ratio(0.65),
                                angularInset: 1
                            )
                            .foregroundStyle(muscleGroupOccurance.0.color.gradient)
                        }
                    }
                    .frame(width: 150, height: 150)
                }
                // MARK: Legend, maybe needed in future...
//                Grid(alignment: .leading) {
//                    GridRow {
//                        ForEach(muscleGroupOccurances.prefix(upTo: muscleGroupOccurances.count / 2 + 1), id:\.0) { muscleGroupOccurance in
//                            HStack {
//                                Circle()
//                                    .frame(width: 5, height: 5)
//                                    .foregroundStyle(muscleGroupOccurance.0.color.gradient)
//                                Text(muscleGroupOccurance.0.description)
//                                    .font(.footnote)
//                            }
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                    }
//                    GridRow {
//                        ForEach(muscleGroupOccurances.suffix(from: muscleGroupOccurances.count / 2 + 1), id:\.0) { muscleGroupOccurance in
//                            HStack {
//                                Circle()
//                                    .frame(width: 5, height: 5)
//                                    .foregroundStyle(muscleGroupOccurance.0.color.gradient)
//                                Text(muscleGroupOccurance.0.description)
//                                    .font(.footnote)
//                            }
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                    }
//                }
                
            }
            .padding(CELL_PADDING)
            .tileStyle()
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    // MAKR: - Supporting Methods
    
    func getOverallMuscleGroupOccurances() -> [(MuscleGroup, Int)] {
        Array(
            workoutRepository.getWorkouts()
                .reduce(
                    [:],
                    { current, workout in
                        current.merging(workout.muscleGroupOccurances, uniquingKeysWith: +)
                    }
                )
                .filter { $0.value > 0 }
        )
        .sorted { (first: (MuscleGroup, Int), second: (MuscleGroup, Int)) in
            first.1 > second.1
        }
    }
    
    private var amountOfOccurances: Int {
        getOverallMuscleGroupOccurances().reduce(0, { $0 + $1.1 })
    }
    
    /// Calculates the smallest number of Muscle Groups that combined account for 51% of the overall sets in the timeframe
    /// - Returns: The focused Muscle Groups
    private func getFocusedMuscleGroups() -> [MuscleGroup] {
        var accumulatedPercetange: Float = 0
        var focusedMuscleGroups = [MuscleGroup]()
        for muscleGroupOccurance in getOverallMuscleGroupOccurances() {
            accumulatedPercetange += Float(muscleGroupOccurance.1) / Float(amountOfOccurances)
            focusedMuscleGroups.append(muscleGroupOccurance.0)
            if accumulatedPercetange > 0.51 {
                return focusedMuscleGroups
            }
        }
        return []
    }
    
}

private var allMuscleGroupZeroDict: [MuscleGroup: Int] {
    MuscleGroup.allCases.reduce(into: [MuscleGroup: Int](), { $0[$1, default: 0] = 0 })
}

#Preview {
    MuscleGroupSplitTile()
        .padding()
        .previewEnvironmentObjects()
}
