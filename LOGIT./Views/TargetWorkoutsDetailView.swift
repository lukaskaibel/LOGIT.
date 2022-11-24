//
//  TargetWorkoutsDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 16.11.22.
//

import SwiftUI

struct TargetWorkoutsDetailView: View {
    
    // MARK: - AppStorage
        
    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var selectedIndexInWeekGroup: Int = 4
    @State private var isShowingWorkoutDetail: Bool = false
    @State private var selectedWorkout: Workout? = nil
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(NSLocalizedString("target", comment: ""))
                        .font(.largeTitle.weight(.bold))
                    Text("/" + NSLocalizedString("week", comment: ""))
                        .fontWeight(.bold)
                }
                .padding([.horizontal, .bottom])
                Spacer()
                Picker(NSLocalizedString("targetPerWeek", comment: ""), selection: $targetPerWeek) {
                    ForEach(1..<10, id:\.self) { i in
                        Text(String(i)).tag(i)
                            .font(.title)
                    }
                }
            }
            SegmentedBarChart(items: workoutsPerWeekChartItems(),
                              hLines: [SegmentedBarChart.HLine(title: NSLocalizedString("target", comment: ""),
                                                               y: targetPerWeek,
                                                               color: .accentColor)],
                              selectedItemIndex: $selectedIndexInWeekGroup)
            .frame(height: 200)
            .overlay {
                if workouts.isEmpty {
                    Text("No Data")
                        .fontWeight(.bold)
                        .foregroundColor(.secondaryLabel)
                }
            }
            .padding()
            HStack(alignment: .lastTextBaseline) {
                Text("Workouts")
                    .sectionHeaderStyle()
                Spacer()
                Text("In Selected Week")
                    .foregroundColor(.secondaryLabel)
                    .textCase(.none)
            }
            .padding(.horizontal)
            TabView(selection: $selectedIndexInWeekGroup) {
                ForEach(0..<5, id:\.self) { i in
                    List {
                        Section {
                            ForEach(workouts(forWeekIndex: i), id:\.objectID) { workout in
                                WorkoutCell(workout: workout)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedWorkout = workout
                                        isShowingWorkoutDetail = true
                                    }
                            }
                            .padding(CELL_PADDING)
                            .tag(i)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .emptyPlaceholder(workouts(forWeekIndex: i)) {
                        Text("No Workouts in Week")
                    }
                }
            }
            .tabViewStyle(.page)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingWorkoutDetail) {
            if let workout = selectedWorkout {
                WorkoutDetailView(workout: workout, canNavigateToTemplate: true)
            }
        }
    }
    
    // MARK: - Supporting Methods
    
    var workouts: [Workout] {
        database.getWorkouts(sortedBy: .date)
    }
    
    private func workouts(forWeekIndex index: Int) -> [Workout] {
        database.getWorkouts(for: .weekOfYear,
                             including: Calendar.current.date(byAdding: .weekOfYear,
                                                              value: -(4 - index),
                                                              to: Date())!)
    }
    
    func workoutsPerWeekChartItems(numberOfWeeks: Int = 5) -> [SegmentedBarChart.Item] {
        var result = [SegmentedBarChart.Item]()
        for i in 0..<numberOfWeeks {
            if let iteratedDay = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) {
                let numberOfWorkoutsInWeek = database.getWorkouts(for: .weekOfYear,
                                                                  including: iteratedDay).count
                result.append(SegmentedBarChart.Item(x: getFirstDayOfWeekString(for: iteratedDay),
                                                     y: numberOfWorkoutsInWeek,
                                                     barColor: i == (4 - selectedIndexInWeekGroup) ? .accentColor :
                                                        numberOfWorkoutsInWeek >= targetPerWeek ? .accentColor.translucentBackground :
                                                        .accentColor.secondaryTranslucentBackground))
                
            }
        }
        return result.reversed()
    }
    
    func getFirstDayOfWeekString(for date: Date) -> String {
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter.string(from: firstDayOfWeek)
    }

    
}

struct TargetWorkoutsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TargetWorkoutsDetailView()
                .environmentObject(Database.preview)
        }
    }
}