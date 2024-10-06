//
//  WorkoutSetsTile.swift
//  LOGIT
//
//  Created by Volker Kaibel on 06.10.24.
//

import Charts
import SwiftUI

struct WorkoutSetsTile: View {
    
    @EnvironmentObject private var workoutRepository: WorkoutRepository
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("overallSets", comment: ""))
                        .tileHeaderStyle()
                    
                }
                Spacer()
                NavigationChevron()
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("currentWeek", comment: ""))
                        .fontWeight(.semibold)
                    Text("\(workoutRepository.getWorkouts(for: [.weekOfYear, .yearForWeekOfYear], including: .now).map({ $0.sets }).joined().count)")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .foregroundStyle(.tint)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                // Chart with sets plotted for this week with days as letters below on x without y label
                Chart {
                    ForEach(setsOfLastWeekGroupedByDay, id:\.first) { workoutSetsGroup in
                        BarMark(
                            x: .value("Day", workoutSetsGroup.first?.workout?.date ?? .now, unit: .day),
                            y: .value("Number of Sets", workoutSetsGroup.count),
                            width: 3
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 1))
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .extended, values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(date.formatted(.dateTime.day(.ordinalOfDayInMonth)))
                                .foregroundStyle(Calendar.current.isDateInToday(date) ? Color.primary : .secondary)
                                .font(.caption.weight(.bold))
                        }
                    }
                }
            }
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }
    
    private var setsOfLastWeekGroupedByDay: [[WorkoutSet]] {
        var result = [[WorkoutSet]]()
        workoutRepository.getWorkouts(for: [.weekOfYear, .yearForWeekOfYear], including: .now)
            .map({ $0.sets })
            .joined()
            .forEach { workoutSet in
                if let lastDate = result.last?.last?.workout?.date,
                    let setGroupDate = workoutSet.workout?.date,
                    Calendar.current.isDate(
                        lastDate,
                        equalTo: setGroupDate,
                        toGranularity: .day
                    )
                {
                    result[result.count - 1].append(workoutSet)
                } else {
                    result.append([workoutSet])
                }
            }
        return result
    }
}

#Preview {
    WorkoutSetsTile()
        .previewEnvironmentObjects()
}
