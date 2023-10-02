//
//  HomeScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 24.09.21.
//

import CoreData
import SwiftUI

struct HomeScreen: View {

    enum NavigationDestinationType: Hashable {
        case targetPerWeek, muscleGroupsOverview, exerciseList, templateList
    }

    // MARK: - AppStorage

    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3

    // MARK: - Environment

    @EnvironmentObject var database: Database

    // MARK: - State

    @State private var navigationDestinationType: NavigationDestinationType?
    @State private var selectedWorkout: Workout?
    @State private var showNoWorkoutTip = false
    @State private var isShowingWorkoutRecorder = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SECTION_SPACING) {
                    header
                        .padding([.horizontal, .top])

                    if showNoWorkoutTip {
                        noWorkoutTip
                            .padding(.horizontal)
                    }

                    VStack(spacing: 0) {
                        Button {
                            navigationDestinationType = .exerciseList
                        } label: {
                            HStack {
                                HStack {
                                    Image(systemName: "dumbbell")
                                        .frame(width: 40)
                                        .foregroundColor(.secondary)
                                    Text(NSLocalizedString("exercises", comment: ""))
                                }
                                Spacer()
                                NavigationChevron()
                            }
                            .padding(.trailing)
                            .padding(.vertical, 12)
                        }
                        Divider()
                            .padding(.leading, 45)
                        Button {
                            navigationDestinationType = .templateList
                        } label: {
                            HStack {
                                HStack {
                                    Image(systemName: "list.bullet.rectangle.portrait")
                                        .frame(width: 40)
                                        .foregroundColor(.secondary)
                                    Text(NSLocalizedString("templates", comment: ""))
                                }
                                Spacer()
                                NavigationChevron()
                            }
                            .padding(.trailing)
                            .padding(.vertical, 12)
                        }
                        Divider()
                            .padding(.leading, 45)
                    }
                    .font(.title2)
                    .padding(.leading)

                    WidgetCollectionView(
                        type: .homeScreen,
                        title: NSLocalizedString("overview", comment: ""),
                        views: [
                            targetWorkoutsView.widget(ofType: .targetPerWeek, isAddedByDefault: true),
                            muscleGroupPercentageView.widget(ofType: .muscleGroupsInLastTen, isAddedByDefault: false),
                            setsPerWeek.widget(ofType: .setsPerWeek, isAddedByDefault: false),
                            workoutsPerMonth.widget(ofType: .workoutsPerMonth, isAddedByDefault: false),
                            volumePerDay.widget(ofType: .homeScreenVolumePerDay, isAddedByDefault: false)
                        ]
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
                .padding(.top)
            }
            .onAppear {
                showNoWorkoutTip = workouts.isEmpty
            }
            .scrollIndicators(.hidden)
            .fullScreenCover(isPresented: $isShowingWorkoutRecorder) {
                WorkoutRecorderScreen(workout: database.newWorkout(), template: nil)
            }
            .navigationDestination(item: $navigationDestinationType) { destination in
                switch destination {
                case .exerciseList: ExerciseListScreen()
                case .templateList: TemplateListScreen()
                case .targetPerWeek: TargetPerWeekDetailScreen()
                case .muscleGroupsOverview:
                    MuscleGroupsDetailScreen(
                        setGroups: (lastTenWorkouts.map { $0.setGroups }).reduce([], +)
                    )
                }
            }
        }
    }

    // MARK: - Supporting Views

    private var header: some View {
        VStack(alignment: .leading) {
            Text(Date.now.formatted(date: .long, time: .omitted))
                .screenHeaderTertiaryStyle()
            Text("LOGIT")
                .screenHeaderStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var targetWorkoutsView: some View {
        Button {
            navigationDestinationType = .targetPerWeek
        } label: {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(
                            "\(NSLocalizedString("lastWorkout", comment: "")) - \(workouts.first?.date?.description(.short) ?? NSLocalizedString("never", comment: ""))"
                        )
                        .tileHeaderTertiaryStyle()
                        Text(NSLocalizedString("workoutTarget", comment: ""))
                            .tileHeaderStyle()
                        Text("\(targetPerWeek) / \(NSLocalizedString("week", comment: ""))")
                            .tileHeaderSecondaryStyle()
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
            .tileStyle()
            .contentShape(Rectangle())
        }
        .buttonStyle(TileButtonStyle())
    }

    private var muscleGroupPercentageView: some View {
        Button {
            navigationDestinationType = .muscleGroupsOverview
        } label: {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("muscleGroups", comment: ""))
                            .tileHeaderStyle()
                        Text(NSLocalizedString("lastTenWorkouts", comment: ""))
                            .tileHeaderSecondaryStyle()
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
            .padding(CELL_PADDING)
            .tileStyle()
            .contentShape(Rectangle())
        }
        .buttonStyle(TileButtonStyle())
    }

    private var setsPerWeek: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("overallSets", comment: ""))
                    .tileHeaderStyle()
                Text(NSLocalizedString("PerWeek", comment: ""))
                    .tileHeaderSecondaryStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateBarChart(dateUnit: .weekOfYear) {
                database.getGroupedWorkoutsSets(in: .weekOfYear)
                    .compactMap {
                        guard let date = $0.first?.workout?.date else { return nil }
                        return DateBarChart.Item(date: date, value: $0.count)
                    }
            }
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }

    private var workoutsPerMonth: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("workouts", comment: ""))
                    .tileHeaderStyle()
                Text(NSLocalizedString("PerMonth", comment: ""))
                    .tileHeaderSecondaryStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateBarChart(dateUnit: .month) {
                database.getGroupedWorkouts(groupedBy: .date(calendarComponent: .month))
                    .compactMap {
                        guard let date = $0.first?.date else { return nil }
                        return DateBarChart.Item(date: date, value: $0.count)
                    }
            }
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }
    
    private var volumePerDay: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("volume", comment: ""))
                    .tileHeaderStyle()
                Text(NSLocalizedString("PerDay", comment: ""))
                    .tileHeaderSecondaryStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateBarChart(dateUnit: .day) {
                volume(per: .day)
                    .map { .init(date: $0.0, value: $0.1) }
            }
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }

    private var noWorkoutTip: some View {
        TipView(
            title: NSLocalizedString("noWorkoutsTip", comment: ""),
            description: NSLocalizedString("noWorkoutsTipDescription", comment: ""),
            buttonAction: .init(
                title: NSLocalizedString("startWorkout", comment: ""),
                action: { isShowingWorkoutRecorder = true }
            ),
            isShown: $showNoWorkoutTip
        )
        .padding(CELL_PADDING)
        .tileStyle()
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
            .environmentObject(MeasurementEntryController.preview)
    }
}
