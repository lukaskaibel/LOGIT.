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
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    targetWorkoutsView
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    navigateToTarget = true
                                }
                        )
                } header: {
                    HStack(alignment: .lastTextBaseline) {
                        Text("Workout Target")
                            .sectionHeaderStyle()
                        Spacer()
                        Text("Per Week")
                            .font(.body)
                            .textCase(nil)
                            .foregroundColor(.secondaryLabel)
                    }
                }.listRowInsets(EdgeInsets())
                Section {
                    muscleGroupPercentageView
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigateToMuscleGroupDetail = true
                        }
                } header: {
                    HStack(alignment: .lastTextBaseline) {
                        Text("Muscle Groups")
                            .sectionHeaderStyle()
                        Spacer()
                        Text("Last 10 Workouts")
                            .font(.body)
                            .textCase(nil)
                            .foregroundColor(.secondaryLabel)
                    }
                }.listRowInsets(EdgeInsets())
                Section(content: {
                    ForEach(recentWorkouts, id:\.objectID) { workout in
                        ZStack {
                            WorkoutCell(workout: workout)
                            NavigationLink(destination: WorkoutDetailView(workout: workout, canNavigateToTemplate: true)) {
                                EmptyView()
                            }.opacity(0)
                        }
                        .padding(CELL_PADDING)
                    }.onDelete { indexSet in
                        for index in indexSet {
                            database.delete(recentWorkouts.value(at: index), saveContext: true)
                        }
                    }
                    .emptyPlaceholder(recentWorkouts) {
                        Text("No Workouts")
                    }
                }, header: {
                    HStack {
                        Text(NSLocalizedString("recentWorkouts", comment: ""))
                            .sectionHeaderStyle()
                            .fixedSize()
                        Spacer()
                        NavigationLink(destination: AllWorkoutsView()) {
                            Text(NSLocalizedString("showAll", comment: ""))
                                .font(.body)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .textCase(.none)
                        }
                    }.listRowSeparator(.hidden, edges: .top)
                }).listRowInsets(EdgeInsets())
                Spacer(minLength: 50)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("LOGIT.")
            .navigationDestination(isPresented: $navigateToTarget) {
                TargetWorkoutsDetailView()
            }
            .navigationDestination(isPresented: $navigateToMuscleGroupDetail) {
                MuscleGroupDetailView(setGroups: (lastTenWorkouts.map { $0.setGroups }).reduce([], +))
            }
        }
    }
    
    private var muscleGroupPercentageView: some View {
        HStack {
            PieGraph(items: getOverallMuscleGroupOccurances()
                                    .map { PieGraph.Item(title: $0.0.description.capitalized,
                                                         amount: $0.1,
                                                         color: $0.0.color) },
                     showZeroValuesInLegend: true)
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
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        Text(NSLocalizedString("Last", comment: ""))
                    }
                    Text("\(workouts.first?.date?.description(.short) ?? NSLocalizedString("never", comment: ""))")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
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
                        Text("No Data")
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
        if lastTenWorkouts.isEmpty {
            return Array(MuscleGroup.allCases.reduce(into: [MuscleGroup:Int](), { $0[$1, default: 0] = 0 })).sorted { $0.key.rawValue < $1.key.rawValue }
        } else {
            return Array(lastTenWorkouts
                .reduce([:], { current, workout in
                    current.merging(workout.muscleGroupOccurances, uniquingKeysWith: +)
                })
            ).sorted { $0.key.rawValue < $1.key.rawValue }
        }
    }
    
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(Database.preview)
    }
}
