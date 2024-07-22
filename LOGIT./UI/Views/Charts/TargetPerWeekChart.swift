//
//  TargetPerWeekChart.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 09.08.23.
//

import SwiftUI

struct TargetPerWeekChart: View {

    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3

    @EnvironmentObject var database: Database
    @EnvironmentObject var workoutRepository: WorkoutRepository

    @Binding var selectedWeeksFromNowIndex: Int?
    let canSelectWeek: Bool
    let grayOutNotSelectedWeeks: Bool

    var body: some View {
        SegmentedStackedBarChart<UUID>(
            selectedCategoryIndex: selectedCategoryIndex,
            canSelectCategory: canSelectWeek,
            grayOutNotSelectedCategories: grayOutNotSelectedWeeks,
            categories: [4, 3, 2, 1, 0].map({
                let workoutsInWeek = workouts(forWeekIndex: -$0)
                return .init(
                    label: weekDescription(forWeeksFromNow: $0),
                    segments: workoutsInWeek.map({
                        .init(items: $0.muscleGroupOccurances.map({
                            .init(
                                id: UUID(),
                                value: $0.1,
                                color: workoutsInWeek.count < targetPerWeek ? $0.0.color.translucentBackground : $0.0.color
                            )
                        }))
                    }))
            })
        )
    }

    // MARK: - Supporting
    
    private var selectedCategoryIndex: Binding<Int?> {
        Binding(
            get: { selectedWeeksFromNowIndex != nil ? (4 + selectedWeeksFromNowIndex!) : nil },
            set: { selectedWeeksFromNowIndex = $0 != nil ? -(4 - $0!) : nil }
        )
    }

    private func workouts(forWeekIndex index: Int) -> [Workout] {
        workoutRepository.getWorkouts(
            for: .weekOfYear,
            including: Calendar.current.date(
                byAdding: .weekOfYear,
                value: index,
                to: .now
            )!
        )
    }

    private func weekDescription(forWeeksFromNow weeksFromNow: Int) -> String {
        let week = Calendar.current.date(byAdding: .weekOfYear, value: -weeksFromNow, to: .now)!
        guard !week.inSameWeekOfYear(as: .now)
        else { return NSLocalizedString("now", comment: "") }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter.string(from: week)
    }

}

struct TargetPerWeekView_Previews: PreviewProvider {
    static var previews: some View {
        TargetPerWeekChart(selectedWeeksFromNowIndex: .constant(nil), canSelectWeek: false, grayOutNotSelectedWeeks: false)
            .previewEnvironmentObjects()
    }
}
