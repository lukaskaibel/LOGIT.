//
//  TargetPerWeekDetailScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 16.11.22.
//

import SwiftUI

struct TargetPerWeekDetailScreen: View {

    // MARK: - AppStorage

    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3

    // MARK: - Environment

    @EnvironmentObject var database: Database

    // MARK: - State

    @State private var selectedIndexInWeekGroup: Int? = 0
    @State private var isShowingWorkoutDetail: Bool = false
    @State private var selectedWorkout: Workout? = nil

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                header
                    .padding([.horizontal, .top])
                TargetPerWeekView(selectedWeeksFromNowIndex: $selectedIndexInWeekGroup)
                    .frame(height: 200)
                    .overlay {
                        if workouts.isEmpty {
                            Text(NSLocalizedString("noData", comment: ""))
                                .fontWeight(.bold)
                                .foregroundColor(.secondaryLabel)
                        }
                    }
                    .padding(.horizontal, 20)
                HStack {
                    Text(NSLocalizedString("targetPerWeek", comment: ""))
                    Spacer()
                    Picker(NSLocalizedString("targetPerWeek", comment: ""), selection: $targetPerWeek) {
                        ForEach(1..<10, id: \.self) { i in
                            Text(String(i)).tag(i)
                        }
                    }
                    .fontWeight(.bold)
                }
                .padding(CELL_PADDING)
                .tileStyle()
                .padding(.horizontal)
                VStack(spacing: SECTION_HEADER_SPACING) {
                    HStack(alignment: .lastTextBaseline) {
                        Text(NSLocalizedString("workouts", comment: ""))
                            .sectionHeaderStyle2()
                        Spacer()
                        Text(NSLocalizedString("inSelectedWeek", comment: ""))
                            .foregroundColor(.secondaryLabel)
                            .textCase(.none)
                    }
                    LazyVStack(spacing: CELL_SPACING) {
                        ForEach(workouts(forWeekIndex: selectedIndexInWeekGroup ?? 0), id: \.objectID) {
                            workout in
                            WorkoutCell(workout: workout)
                                .padding(CELL_PADDING)
                                .tileStyle()
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedWorkout = workout
                                    isShowingWorkoutDetail = true
                                }
                        }
                        .emptyPlaceholder(workouts(forWeekIndex: selectedIndexInWeekGroup ?? 0)) {
                            Text(NSLocalizedString("noWorkoutsInWeek", comment: ""))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingWorkoutDetail) {
            if let workout = selectedWorkout {
                WorkoutDetailScreen(workout: workout, canNavigateToTemplate: true)
            }
        }
    }
    
    // MARK: - Supporting Views
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("target", comment: ""))
                .screenHeaderStyle()
            Text("\(targetPerWeek) / \(NSLocalizedString("week", comment: ""))")
                .screenHeaderSecondaryStyle()
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Supporting Methods

    var workouts: [Workout] {
        database.getWorkouts(sortedBy: .date)
    }

    private func workouts(forWeekIndex index: Int) -> [Workout] {
        database.getWorkouts(
            for: .weekOfYear,
            including: Calendar.current.date(
                byAdding: .weekOfYear,
                value: index - 1,
                to: .now
            )!
        )
    }

    func getFirstDayOfWeekString(for date: Date) -> String {
        let firstDayOfWeek = Calendar.current
            .dateComponents(
                [.calendar, .yearForWeekOfYear, .weekOfYear],
                from: date
            )
            .date!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter.string(from: firstDayOfWeek)
    }

}

struct TargetWorkoutsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TargetPerWeekDetailScreen()
        }
        .environmentObject(Database.preview)
    }
}
