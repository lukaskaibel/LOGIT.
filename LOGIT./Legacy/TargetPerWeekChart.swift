//
//  TargetPerWeekChart.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 09.08.23.
//

import Charts
import SwiftUI

struct TargetPerWeekChart: View {
    
    // MARK: - Constants
    
    private let segmentSpacing: Float = 0.06
    private let standardBarWidth: MarkDimension = .init(integerLiteral: 30)

    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3

    @EnvironmentObject var database: Database
    @EnvironmentObject var workoutRepository: WorkoutRepository

    @Binding var selectedWeeksFromNowIndex: Int?
    let canSelectWeek: Bool
    let grayOutNotSelectedWeeks: Bool

    var body: some View {
        Chart {
            ForEach([4, 3, 2, 1, 0], id: \.self) { weeksFromNow in
                let workoutsInWeek = workouts(forWeekIndex: -weeksFromNow)
                if workoutsInWeek.isEmpty {
                    BarMark(
                        x: .value("Bar x value", weekDescription(forWeeksFromNow: weeksFromNow)),
                        y: .value("Placeholder", 1),
                        width:  standardBarWidth
                    )
                        .foregroundStyle(Color.clear)
                }
                BarMark(
                    x: .value("Bar x value", weekDescription(forWeeksFromNow: weeksFromNow)),
                    y: .value("Bar y value", workoutsInWeek.count),
                    width:  standardBarWidth
                )
                .foregroundStyle(.white)
                BarMark(
                    x: .value("Bar x value", weekDescription(forWeeksFromNow: weeksFromNow)),
                    yStart: .value("Bar y start value", 0),
                    yEnd: .value("Bar y end value", targetPerWeek),
                    width:  standardBarWidth
                )
                .foregroundStyle(Color.placeholder)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) { value in
                if let label = value.as(String.self) {
                    AxisValueLabel(label)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(4 - value.index == selectedWeeksFromNowIndex ? Color.primary : Color.secondary)
                }
            }
        }
        .chartYAxis(.hidden)
        .overlay {
            if canSelectWeek {
                HStack {
                    ForEach(Array([4, 3, 2, 1, 0].enumerated()), id: \.element) { index, weeksFromNow in
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                TapGesture().onEnded { _ in
                                    if weeksFromNow != selectedWeeksFromNowIndex && !workouts(forWeekIndex: -weeksFromNow).isEmpty {
                                        UISelectionFeedbackGenerator().selectionChanged()
                                        selectedWeeksFromNowIndex = weeksFromNow
                                    }
                                }
                            )
                    }
                }
            }
        }
        .animation(.none)
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
            for: [.weekOfYear, .yearForWeekOfYear],
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

// MARK: - Preview

private struct TargetPerWeekPreviewView: View {
    
    @State private var selectedWeeksFromNowIndex: Int? = 0
    
    var body: some View {
        TargetPerWeekChart(
            selectedWeeksFromNowIndex: $selectedWeeksFromNowIndex,
            canSelectWeek: true,
            grayOutNotSelectedWeeks: false
        )
    }
    
}

struct TargetPerWeekView_Previews: PreviewProvider {
    static var previews: some View {
        TargetPerWeekPreviewView()
            .previewEnvironmentObjects()
    }
}
