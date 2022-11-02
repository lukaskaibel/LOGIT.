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

    @State private var isShowingTemplateEditor = false
    @State private var isShowingNewTemplate = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    targetWorkoutsView
                } header: {
                    Text("Workout Target")
                        .sectionHeaderStyle()
                }.listRowSeparator(.hidden)
                Section {
                    muscleGroupPercentageView
                } header: {
                    Text("Sets per Muscle Group")
                        .sectionHeaderStyle()
                }.listRowSeparator(.hidden)
                Section(content: {
                    ForEach(recentWorkouts, id:\.objectID) { workout in
                        ZStack {
                            WorkoutCell(workout: workout)
                            NavigationLink(destination: WorkoutDetailView(workout: workout, canNavigateToTemplate: true)) {
                                EmptyView()
                            }.opacity(0)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }.onDelete { indexSet in
                        for index in indexSet {
                            database.delete(recentWorkouts.value(at: index), saveContext: true)
                        }
                    }
                }, header: {
                    HStack {
                        Text(NSLocalizedString("recentWorkouts", comment: ""))
                            .foregroundColor(.label)
                            .font(.title2.weight(.bold))
                            .fixedSize()
                        Spacer()
                        NavigationLink(destination: AllWorkoutsView()) {
                            Text(NSLocalizedString("showAll", comment: ""))
                                .font(.body)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }.listRowSeparator(.hidden, edges: .top)
                })
                Spacer(minLength: 50)
                    .listRowSeparator(.hidden)
            }.listStyle(.plain)
                .navigationTitle(NSLocalizedString("home", comment: ""))
        } .navigationViewStyle(.stack)
        .sheet(isPresented: $isShowingTemplateEditor) {
            TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor())
        }
        .sheet(isPresented: $isShowingNewTemplate) {
            TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor())
        }
    }
    
    private var muscleGroupPercentageView: some View {
        PieGraph(items: getOverallMuscleGroupOccurances()
                                .map { PieGraph.Item(title: $0.0.description.capitalized,
                                                     amount: $0.1,
                                                     color: $0.0.color) },
                 showZeroValuesInLegend: true)
            .tileStyle()
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
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                        Text(NSLocalizedString("Streak", comment: ""))
                    }
                    UnitView(value: "\(targetPerWeek)", unit: NSLocalizedString("weeks", comment: ""))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        Text(NSLocalizedString("Last", comment: ""))
                    }
                    Text("\(workouts.last?.date?.description(.short) ?? NSLocalizedString("never", comment: ""))")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            TargetPerWeekGraph(xValues: getWeeksString().reversed(),
                              yValues: workoutsPerWeek(for: numberOfWeeksInAnalysis).reversed(),
                              target: targetPerWeek)
                .frame(height: 170)
                .overlay {
                    if workouts.isEmpty {
                        Text("No Data")
                            .fontWeight(.bold)
                            .foregroundColor(.secondaryLabel)
                    }
                }
        }.tileStyle()
    }
    
    // MARK: - Supportings Methods
    
    var workouts: [Workout] {
        database.getWorkouts(sortedBy: .date)
    }
    
    var recentWorkouts: [Workout] {
        Array(database.getWorkouts(sortedBy: .date).prefix(8))
    }
    
    func workoutsPerWeek(for numberOfWeeks: Int) -> [Int] {
        var result = [Int](repeating: 0, count: numberOfWeeks)
        for i in 0..<numberOfWeeks {
            if let iteratedDay = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) {
                for workout in workouts {
                    if let workoutDate = workout.date {
                        if Calendar.current.isDate(workoutDate, equalTo: iteratedDay, toGranularity: .weekOfYear) {
                            result[i] += 1
                        }
                    }
                }
            }
        }
        return result
    }
    
    func barColorsForWeeks() -> [Color] {
        workoutsPerWeek(for: numberOfWeeksInAnalysis).map { $0 >= targetPerWeek ? .accentColor : .accentColor }
    }
    
    func getWeeksString() -> [String] {
        var result = [String]()
        for i in 0..<numberOfWeeksInAnalysis {
            if let iteratedDay = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) {
                result.append(getFirstDayOfWeekString(for: iteratedDay))
            }
        }
        return result
    }
    
    func getFirstDayOfWeekString(for date: Date) -> String {
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter.string(from: firstDayOfWeek)
    }
    
    func getOverallMuscleGroupOccurances() -> [(MuscleGroup, Int)] {
        Array(workouts
            .reduce([:], { current, workout in
                current.merging(workout.muscleGroupOccurances, uniquingKeysWith: +)
            })
        ).sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    // MARK: Constants
    
    let numberOfWeeksInAnalysis = 5
    
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(Database.preview)
    }
}
