//
//  HomeView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 24.09.21.
//

import SwiftUI
import CoreData

struct HomeView: View {
    
    // MARK: - AppStorage
        
    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var navigateToTarget: Bool = false
    @State private var navigateToMuscleGroupDetail: Bool = false
    @State private var selectedWorkout: Workout?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: SECTION_SPACING) {
                    VStack(spacing: SECTION_HEADER_SPACING) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Workout Target")
                                .sectionHeaderStyle2()
                            Spacer()
                            Text("Per Week")
                                .sectionHeaderSecondaryStyle()
                        }
                        targetWorkoutsView
                            .tileStyle()
                            .contentShape(Rectangle())
                            .highPriorityGesture(
                                TapGesture()
                                    .onEnded {
                                        navigateToTarget = true
                                    }
                            )
                    }
                    .padding(.horizontal)

                    VStack(spacing: SECTION_HEADER_SPACING) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Muscle Groups")
                                .sectionHeaderStyle2()
                            Spacer()
                            Text("Last 10 Workouts")
                                .sectionHeaderSecondaryStyle()
                        }
                        muscleGroupPercentageView
                            .tileStyle()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                navigateToMuscleGroupDetail = true
                            }
                    }
                    .padding(.horizontal)

                    VStack(spacing: SECTION_HEADER_SPACING) {
                        HStack {
                            Text(NSLocalizedString("recentWorkouts", comment: ""))
                                .sectionHeaderStyle2()
                                .fixedSize()
                            NavigationLink(destination: AllWorkoutsView()) {
                                Text(NSLocalizedString("showAll", comment: ""))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        VStack(spacing: CELL_SPACING) {
                            ForEach(recentWorkouts, id:\.objectID) { workout in
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
                .padding(.bottom, 50)
                .padding(.top)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("LOGIT.")
            .navigationDestination(isPresented: $navigateToTarget) {
                TargetWorkoutsDetailView()
            }
            .navigationDestination(isPresented: $navigateToMuscleGroupDetail) {
                MuscleGroupDetailView(setGroups: (lastTenWorkouts.map { $0.setGroups }).reduce([], +))
            }
            .navigationDestination(for: Workout.self) { selectedWorkout in
                WorkoutDetailView(workout: selectedWorkout, canNavigateToTemplate: true)
            }
        }
    }
    
    private var muscleGroupPercentageView: some View {
        HStack {
            PieGraph(
                items:
                    getOverallMuscleGroupOccurances().map {
                        PieGraph.Item(title: $0.0.description.capitalized,
                                      amount: $0.1,
                                      color: $0.0.color,
                                      isSelected: false)
                    },
                showZeroValuesInLegend: true
            )
            Spacer()
            NavigationChevron()
                .foregroundColor(.secondaryLabel)
        }
        .padding(CELL_PADDING)
    }
    
    private var targetWorkoutsView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "target")
                        Text(NSLocalizedString("target", comment: ""))
                    }
                    UnitView(value: "\(targetPerWeek)", unit: "/"+NSLocalizedString("week", comment: ""))
                        .foregroundStyle(Color.accentColor.gradient)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        Text(NSLocalizedString("Last", comment: ""))
                    }
                    Text("\(workouts.first?.date?.description(.short) ?? NSLocalizedString("never", comment: ""))")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.accentColor.gradient)
                }.frame(maxWidth: .infinity, alignment: .leading)
                NavigationChevron()
                    .foregroundColor(.secondaryLabel)
            }
            SegmentedBarChart(items: workoutsPerWeekChartItems(),
                              hLines: [SegmentedBarChart.HLine(title: NSLocalizedString("target", comment: ""),
                                                               y: targetPerWeek,
                                                               color: .accentColor)],
                              selectedItemIndex: .constant(4))
                .frame(height: 170)
                .overlay {
                    if workouts.isEmpty {
                        Text(NSLocalizedString("noData", comment: ""))
                            .font(.title3.weight(.medium))
                            .foregroundColor(.placeholder)
                    }
                }
        }.padding(CELL_PADDING)
    }
    
    // MARK: - Supportings Methods
    
    var workouts: [Workout] {
        database.getWorkouts(sortedBy: .date)
    }
    
    var recentWorkouts: [Workout] {
        Array(database.getWorkouts(sortedBy: .date).prefix(3))
    }
    
    func workoutsPerWeekChartItems(numberOfWeeks: Int = 5) -> [SegmentedBarChart.Item] {
        var result = [SegmentedBarChart.Item]()
        for i in 0..<numberOfWeeks {
            if let iteratedDay = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) {
                let numberOfWorkoutsInWeek = database.getWorkouts(for: .weekOfYear,
                                                                  including: iteratedDay).count
                result.append(SegmentedBarChart.Item(x: getFirstDayOfWeekString(for: iteratedDay),
                                                     y: numberOfWorkoutsInWeek,
                                                     barColor: numberOfWorkoutsInWeek >= targetPerWeek ? .accentColor.translucentBackground : .accentColor.secondaryTranslucentBackground))
                
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
    
    var lastTenWorkouts: [Workout] {
        Array(workouts.prefix(10))
    }
    
    func getOverallMuscleGroupOccurances() -> [(MuscleGroup, Int)] {
        Array(lastTenWorkouts
            .reduce([:], { current, workout in
                current.merging(workout.muscleGroupOccurances, uniquingKeysWith: +)
            })
            .merging(allMuscleGroupZeroDict, uniquingKeysWith: +)
        ).sorted { MuscleGroup.allCases.firstIndex(of: $0.key)! < MuscleGroup.allCases.firstIndex(of: $1.key)! }
    }
    
}

private var allMuscleGroupZeroDict: [MuscleGroup:Int] {
    MuscleGroup.allCases.reduce(into: [MuscleGroup:Int](), { $0[$1, default: 0] = 0 })
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(Database.preview)
    }
}
