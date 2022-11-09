//
//  ExerciseDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.01.22.
//

import SwiftUI
import CoreData
import Charts

struct ExerciseDetailView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var sortingKey: Database.WorkoutSetSortingKey = .date
    @State private var selectedCalendarComponent: Calendar.Component = .weekOfYear
    @State private var showDeletionAlert = false
    @State private var showingEditExercise = false
    
    // MARK: - Variables
    
    let exercise: Exercise
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                header
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            Section {
                exerciseInfo
                    .padding(CELL_PADDING)
            } header: {
                Text("Personal Best")
                    .sectionHeaderStyle()
            }
            .listRowInsets(EdgeInsets())
            Section {
                weightGraph
            } header: {
                Text(NSLocalizedString("weight", comment: ""))
                    .sectionHeaderStyle()
            }.listRowInsets(EdgeInsets())
            Section(content: {
                ForEach(setsForExercise) { workoutSet in
                    if workoutSet.hasEntry {
                        HStack {
                            Text(dateString(for: workoutSet))
                            Spacer()
                            WorkoutSetCell(workoutSet: workoutSet)
                        }
                    }
                }
            }, header: {
                VStack(spacing: 0) {
                    HStack {
                        Text(NSLocalizedString("sets", comment: ""))
                            .sectionHeaderStyle()
                            .fixedSize()
                        Spacer()
                        Menu {
                            Button(action: {
                                sortingKey = .date
                            }) {
                                Label(NSLocalizedString("date", comment: ""), systemImage: "calendar")
                            }
                            Button(action: {
                                sortingKey = .maxRepetitions
                            }) {
                                Label(NSLocalizedString("repetitions", comment: ""), systemImage: "arrow.counterclockwise")
                            }
                            Button(action: {
                                sortingKey = .maxWeight
                            }) {
                                Label(NSLocalizedString("weight", comment: ""), systemImage: "scalemass")
                            }
                        } label: {
                            Label(NSLocalizedString(sortingKey == .date ? "date" : sortingKey == .maxRepetitions ? "repetitions" : "weight", comment: ""),
                                  systemImage: "arrow.up.arrow.down")
                            .font(.body)
                        }.textCase(.none)
                    }
                    HStack(spacing: SetGroupDetailView.columnSpace) {
                        Text(NSLocalizedString("date", comment: ""))
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .frame(maxWidth: SetGroupDetailView.columnWidth, alignment: .leading)
                        Spacer()
                        Text(NSLocalizedString("reps", comment: "").uppercased())
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .frame(maxWidth: SetGroupDetailView.columnWidth)
                        Text(WeightUnit.used.rawValue.uppercased())
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .frame(maxWidth: SetGroupDetailView.columnWidth)
                    }.padding(.vertical, 5)
                    Divider()
                }
            }, footer: {
                Text("\(setsForExercise.filter { $0.hasEntry }.count) \(NSLocalizedString("set\(setsForExercise.count == 1 ? "" : "s")", comment: ""))")
                    .foregroundColor(.secondaryLabel)
                    .font(.footnote)
                    .padding(.top, 5)
                    .padding(.bottom, 50)
                    .listRowSeparator(.hidden, edges: .bottom)
            }).listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            Spacer(minLength: 50)
                .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .offset(x: 0, y: -30)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .tint(muscleGroupColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button(action: { showingEditExercise.toggle() }, label: { Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil") })
                    Button(role: .destructive, action: { showDeletionAlert.toggle() }, label: { Label(NSLocalizedString("delete", comment: ""), systemImage: "trash") } )
                }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(Text(NSLocalizedString("deleteExerciseConfirmation", comment: "")), isPresented: $showDeletionAlert, titleVisibility: .visible) {
            Button("\(NSLocalizedString("delete", comment: ""))", role: .destructive, action: {
                database.delete(exercise, saveContext: true)
                dismiss()
            })
        }
        .sheet(isPresented: $showingEditExercise) {
            EditExerciseView(exerciseToEdit: exercise)
        }
    }
    
    // MARK: - Supporting Views
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(exercise.name ?? "")
                .font(.largeTitle.weight(.bold))
                .lineLimit(2)
            Text(exercise.muscleGroup?.description.capitalized ?? "")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundColor(exercise.muscleGroup?.color ?? .clear)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var exerciseInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("maxReps", comment: ""))
                UnitView(value: String(personalBest(for: .repetitions)), unit: NSLocalizedString("rps", comment: ""))
                    .foregroundColor(exercise.muscleGroup?.color ?? .label)
            }.frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading) {
                Text(NSLocalizedString("maxWeight", comment: ""))
                UnitView(value: String(personalBest(for: .weight)), unit: WeightUnit.used.rawValue.capitalized)
                    .foregroundColor(exercise.muscleGroup?.color ?? .label)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var weightGraph: some View {
        VStack {
            Chart {
                ForEach(personalBests(for: .weight, per: selectedCalendarComponent)) { chartEntry in
                    LineMark(x: .value("CalendarComponent", chartEntry.xValue),
                             y: .value("Weight", chartEntry.yValue))
                    .foregroundStyle(muscleGroupColor)
                    AreaMark(x: .value("CalendarComponent", chartEntry.xValue),
                             y: .value("Weight", chartEntry.yValue))
                    .foregroundStyle(.linearGradient(colors: [muscleGroupColor.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
                }
            }.frame(height: 180)
            Picker("Calendar Component", selection: $selectedCalendarComponent) {
                Text(NSLocalizedString("weekly", comment: "")).tag(Calendar.Component.weekOfYear)
                Text(NSLocalizedString("monthly", comment: "")).tag(Calendar.Component.month)
                Text(NSLocalizedString("yearly", comment: "")).tag(Calendar.Component.year)
            }.pickerStyle(.segmented)
                .padding(.top)
        }.padding(CELL_PADDING)
    }
    
    private var dividerCircle: some View {
        Circle()
            .foregroundColor(.separator)
            .frame(width: 4, height: 4)
    }
    
    // MARK: - Supporting Methods
    
    func personalBest(for attribute: WorkoutSet.Attribute) -> Int {
        database.getWorkoutSets(with: exercise)
            .map { workoutSet in
                return attribute == .repetitions ? workoutSet.maxRepetitions : convertWeightForDisplaying(workoutSet.maxWeight)
            }
            .max() ?? 0
    }
    
    struct ChartEntry: Identifiable {
        let id = UUID()
        let xValue: String
        let yValue: Int
    }
    
    func personalBests(for attribute: WorkoutSet.Attribute, per calendarComponent: Calendar.Component) -> [ChartEntry] {
        let numberOfValues = calendarComponent == .month ? 12 : 5
        var result = [(String, Int)](repeating: ("", 0), count: numberOfValues)
        for i in 0..<numberOfValues {
            guard let iteratedDay = Calendar.current.date(byAdding: calendarComponent,
                                                          value: -i,
                                                          to: Date()) else { continue }
            result[i].0 = getFirstDayString(in: calendarComponent, for: iteratedDay)
            for workoutSet in exercise.sets {
                guard let setDate = workoutSet.setGroup?.workout?.date,
                        Calendar.current.isDate(setDate,
                                                equalTo: iteratedDay,
                                                toGranularity: calendarComponent) else { continue }
                switch attribute {
                case .repetitions: result[i].1 = max(result[i].1, Int(workoutSet.maxRepetitions))
                case .weight: result[i].1 = max(result[i].1, convertWeightForDisplaying(workoutSet.maxWeight))
                }
            }
        }
        return result.reversed().map { ChartEntry(xValue: $0.0, yValue: $0.1) }
    }
    
    private func getFirstDayString(in component: Calendar.Component, for date: Date) -> String {
        let firstDayOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = component == .weekOfYear ? "dd.MM." : component == .month ? "MMM" : "yyyy"
        return formatter.string(from: firstDayOfWeek)
    }
    
    private var setsForExercise: [WorkoutSet] {
        database.getWorkoutSets(with: exercise, sortedBy: sortingKey)
    }
    
    private func dateString(for workoutSet: WorkoutSet) -> String {
        if let date = workoutSet.setGroup?.workout?.date {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .short
            return formatter.string(from: date)
        } else {
            return ""
        }
    }
    
    private var muscleGroupColor: Color {
        exercise.muscleGroup?.color ?? .accentColor
    }
    
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: Database.preview.newExercise(name: "Pushup"))
    }
}
