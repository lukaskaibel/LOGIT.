//
//  HomeScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 24.09.21.
//

import CoreData
import SwiftUI

struct HomeScreen: View {

    // MARK: - AppStorage

    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3

    // MARK: - Environment

    @EnvironmentObject var database: Database

    // MARK: - State

    @State private var navigateToTarget: Bool = false
    @State private var navigateToMuscleGroupDetail: Bool = false
    @State private var navigateToWorkoutList: Bool = false
    @State private var selectedWorkout: Workout?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: SECTION_SPACING) {
                    header
                        .padding([.horizontal, .top])
                    
                    Button {
                        navigateToTarget = true
                    } label: {
                        targetWorkoutsView
                            .tileStyle()
                            .contentShape(Rectangle())
                    }
                    .padding(.horizontal)

                    Button {
                        navigateToMuscleGroupDetail = true
                    } label: {
                        muscleGroupPercentageView
                            .padding(CELL_PADDING)
                            .tileStyle()
                            .contentShape(Rectangle())
                    }
                    .padding(.horizontal)

                    VStack(spacing: SECTION_HEADER_SPACING) {
                        HStack {
                            Text(NSLocalizedString("recentWorkouts", comment: ""))
                                .sectionHeaderStyle2()
                                .fixedSize()
                            Button(NSLocalizedString("showAll", comment: "")) {
                                navigateToWorkoutList = true
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        VStack(spacing: CELL_SPACING) {
                            ForEach(recentWorkouts, id: \.objectID) { workout in
                                NavigationLink(value: workout) {
                                    WorkoutCell(workout: workout)
                                        .padding(CELL_PADDING)
                                        .tileStyle()
                                }
                            }
                            .emptyPlaceholder(recentWorkouts) {
                                Text("No Workouts")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
                .padding(.top)
            }
            .scrollIndicators(.hidden)
            .navigationDestination(isPresented: $navigateToTarget) {
                TargetPerWeekDetailScreen()
            }
            .navigationDestination(isPresented: $navigateToMuscleGroupDetail) {
                MuscleGroupsDetailScreen(
                    setGroups: (lastTenWorkouts.map { $0.setGroups }).reduce([], +)
                )
            }
            .navigationDestination(isPresented: $navigateToWorkoutList) {
                WorkoutListScreen()
            }
            .navigationDestination(for: Workout.self) { selectedWorkout in
                WorkoutDetailScreen(workout: selectedWorkout, canNavigateToTemplate: true)
            }
        }
    }
    
    // MARK: - Supporting Views
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text(Date.now.formatted(date: .long, time: .omitted))
                .screenHeaderTertiaryStyle()
            Text("LOGIT.")
                .screenHeaderStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var targetWorkoutsView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(
                        "Last Workout - \(workouts.first?.date?.description(.short) ?? NSLocalizedString("never", comment: ""))"
                    )
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.secondaryLabel)
                    Text("Workout Target")
                        .sectionHeaderStyle2()
                    Text("\(targetPerWeek) / Week")
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                NavigationChevron()
                    .foregroundColor(.secondaryLabel)
            }
            TargetPerWeekView(selectedWeeksFromNowIndex: .constant(nil))
            .frame(height: 170)
            .overlay {
                if workouts.isEmpty {
                    Text(NSLocalizedString("noData", comment: ""))
                        .font(.title3.weight(.medium))
                        .foregroundColor(.placeholder)
                }
            }
        }
        .padding(CELL_PADDING)
    }

    private var muscleGroupPercentageView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Muscle Groups")
                        .sectionHeaderStyle2()
                    Text("Last 10 Workouts")
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundColor(.secondary)
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
                showZeroValuesInLegend: true
            )
        }
    }

    // MARK: - Supportings Methods

    var workouts: [Workout] {
        database.getWorkouts(sortedBy: .date)
    }

    var recentWorkouts: [Workout] {
        Array(database.getWorkouts(sortedBy: .date).prefix(3))
    }

    var lastTenWorkouts: [Workout] {
        Array(workouts.prefix(10))
    }

    func getOverallMuscleGroupOccurances() -> [(MuscleGroup, Int)] {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environmentObject(Database.preview)
    }
}
