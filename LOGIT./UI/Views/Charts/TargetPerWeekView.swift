//
//  TargetPerWeekView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 09.08.23.
//

import Charts
import SwiftUI

struct TargetPerWeekView: View {

    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3

    @EnvironmentObject var database: Database

    @Binding var selectedWeeksFromNowIndex: Int?

    var body: some View {
        Chart {
            RuleMark(y: .value("Target", targetPerWeek))
                .foregroundStyle(Color.secondary)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
            //                .annotation(position: .bottom, alignment: .leading) {
            //                    Text(NSLocalizedString("target", comment: ""))
            //                        .font(.footnote.weight(.semibold))
            //                        .foregroundColor(.secondary)
            //                }
            ForEach(-4...0, id: \.self) { weeksFromNow in
                let workoutsInWeek = workouts(forWeekIndex: weeksFromNow)
                ForEach(workoutsInWeek.indices, id: \.self) { index in
                    if let workout = workoutsInWeek.value(at: index) {
                        BarMark(
                            x: .value("Week", weeksFromNow),
                            yStart: .value("Workouts in Week", barMarkYStart(for: index)),
                            yEnd: .value("Workouts in Week", barMarkYEnd(for: index)),
                            width: 25
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: workout.muscleGroups
                                    .map { $0.color },
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                            .opacity(workoutsInWeek.count < targetPerWeek ? 0.5 : 1.0)
                        )
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .stride(by: 1)) { value in
                if let weeksFromNow = value.as(Int.self) {
                    AxisValueLabel(
                        weekDescription(
                            Calendar.current.date(
                                byAdding: .weekOfYear,
                                value: weeksFromNow,
                                to: .now
                            )!
                            .startOfWeek
                        )
                    )
                    .font(.caption.weight(.bold))
                    .foregroundStyle(
                        weeksFromNow == (selectedWeeksFromNowIndex ?? 0)
                            ? Color.primary : Color.secondary
                    )
                }
            }
        }
        .chartXScale(domain: [-4, 0])
        .chartYAxis(.hidden)
        .padding(.horizontal)
        .overlay {
            if selectedWeeksFromNowIndex != nil {
                HStack {
                    ForEach(-4...0, id: \.self) { index in
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if index != selectedWeeksFromNowIndex {
                                    UISelectionFeedbackGenerator().selectionChanged()
                                }
                                selectedWeeksFromNowIndex = index
                            }
                    }
                }
            }
        }
    }

    // MARK: - Supporting

    private func workouts(forWeekIndex index: Int) -> [Workout] {
        database.getWorkouts(
            for: .weekOfYear,
            including: Calendar.current.date(
                byAdding: .weekOfYear,
                value: index,
                to: .now
            )!
        )
    }

    private func weekDescription(_ startOfWeek: Date) -> String {
        guard !startOfWeek.inSameWeekOfYear(as: .now)
        else { return NSLocalizedString("now", comment: "") }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter.string(from: startOfWeek)
    }

    // Needed because preview sucks and isn't able to work otherwise...
    private func barMarkYStart(for index: Int) -> Float {
        Float(index) + 0.06
    }

    private func barMarkYEnd(for index: Int) -> Float {
        Float(index) + 1.02
    }
}

struct TargetPerWeekView_Previews: PreviewProvider {
    static var previews: some View {
        TargetPerWeekView(selectedWeeksFromNowIndex: .constant(nil))
            .previewEnvironmentObjects()
    }
}
