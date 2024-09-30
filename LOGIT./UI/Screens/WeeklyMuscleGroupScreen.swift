//
//  WeeklyMuscleGroupScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 16.09.24.
//

import Charts
import SwiftUI

struct WeeklyMuscleGroupScreen: View {
    
    @EnvironmentObject var workoutRepository: WorkoutRepository
    
    var body: some View {
        VStack(spacing: SECTION_SPACING) {
            let muscleGroupOccurances = getOverallMuscleGroupOccurances()
            VStack(alignment: .leading) {
                Text(NSLocalizedString("muscleGroupSplit", comment: ""))
                    .screenHeaderStyle()
                Text(NSLocalizedString("lastTenWorkouts", comment: ""))
                    .screenHeaderSecondaryStyle()
                    .foregroundColor(.secondaryLabel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            if #available(iOS 17.0, *) {
                HStack {
                    Text(NSLocalizedString("currentWeek", comment: ""))
                        .sectionHeaderStyle2()
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
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
                .frame(width: 200, height: 200)
                
                
            } else {
                // Fallback on earlier versions
            }
            Spacer()
            VStack {
                HStack {
                    muscleGroupPercentageButton(for: .chest, occuring: getNumberOfOccurances(for: .chest))
                    muscleGroupPercentageButton(for: .back, occuring: getNumberOfOccurances(for: .back))
                }
                HStack {
                    muscleGroupPercentageButton(for: .triceps, occuring: getNumberOfOccurances(for: .triceps))
                    muscleGroupPercentageButton(for: .biceps, occuring: getNumberOfOccurances(for: .biceps))
                }
                HStack {
                    muscleGroupPercentageButton(for: .legs, occuring: getNumberOfOccurances(for: .triceps))
                    muscleGroupPercentageButton(for: .shoulders, occuring: getNumberOfOccurances(for: .biceps))
                }
                HStack {
                    muscleGroupPercentageButton(for: .abdominals, occuring: getNumberOfOccurances(for: .abdominals))
                    muscleGroupPercentageButton(for: .cardio, occuring: getNumberOfOccurances(for: .cardio))
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MAKR: - Supporting Methods
    
    func getOverallMuscleGroupOccurances() -> [(MuscleGroup, Int)] {
        Array(
            workoutRepository.getWorkouts(for: [.weekOfYear, .yearForWeekOfYear], including: .now)
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
    
    private func getNumberOfOccurances(for muscleGroup: MuscleGroup) -> Int {
        getOverallMuscleGroupOccurances().first(where: { $0.0 == muscleGroup })?.1 ?? 0
    }
    
    @ViewBuilder
    private func muscleGroupPercentageButton(for muscleGroup: MuscleGroup, occuring muscleGroupOccurances: Int) -> some View {
        let percentage = Int(round(100 * Float(muscleGroupOccurances) / Float(amountOfOccurances)))
        Button {
            
        } label: {
            VStack(alignment: .leading) {
                Text(muscleGroup.description)
                    .foregroundStyle(.white)
                UnitView(
                    value: "\(percentage)",
                    unit: "%"
                )
                .foregroundStyle(muscleGroup.color)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(muscleGroup.color.secondaryTranslucentBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    WeeklyMuscleGroupScreen()
        .previewEnvironmentObjects()
}

