//
//  ExerciseDetailScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.01.22.
//

import SwiftUI
import CoreData
import Charts

struct ExerciseDetailScreen: View {
    
    enum TimeSpan {
        case threeMonths, year, allTime
    }
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var selectedTimeSpan: TimeSpan = .threeMonths
    @State private var showDeletionAlert = false
    @State private var showingEditExercise = false
    
    // MARK: - Variables
    
    let exercise: Exercise
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: SECTION_SPACING) {
                header
                    .padding(.horizontal)
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("overview", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack {
                        exerciseInfo
                        weightRepetitionsGraph
                    }
                    .padding(CELL_PADDING)
                    .tileStyle()
                }
                .padding(.horizontal)
                setGroupList
                    .padding(.horizontal)
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(exercise.muscleGroup?.color ?? .accentColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditExercise.toggle() }, label: { Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil") })
                    Button(role: .destructive, action: { showDeletionAlert.toggle() }, label: { Label(NSLocalizedString("delete", comment: ""), systemImage: "trash") } )
                } label: {
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
            ExerciseEditScreen(exerciseToEdit: exercise)
        }
    }
    
    // MARK: - Supporting Views
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text(exercise.name ?? "")
                .font(.largeTitle.weight(.bold))
                .lineLimit(2)
            Text(exercise.muscleGroup?.description.capitalized ?? "")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundStyle((exercise.muscleGroup?.color ?? .clear).gradient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var exerciseInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("maxReps", comment: ""))
                UnitView(value: String(personalBest(for: .repetitions)), unit: NSLocalizedString("rps", comment: ""))
                    .foregroundStyle((exercise.muscleGroup?.color ?? .label).gradient)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            VStack(alignment: .leading) {
                Text(NSLocalizedString("maxWeight", comment: ""))
                UnitView(value: String(personalBest(for: .weight)), unit: WeightUnit.used.rawValue.capitalized)
                    .foregroundStyle((exercise.muscleGroup?.color ?? .label).gradient)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var weightRepetitionsGraph: some View {
        VStack {
            TabView {
                VStack {
                    Text(NSLocalizedString("weight", comment: ""))
                        .font(.body.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Chart {
                        if selectedTimeSpan != .allTime || !firstPerformedOverOneYearAgo {
                            PointMark(x: .value(
                                "Day",
                                Calendar.current.date(byAdding: selectedTimeSpan == .threeMonths ? .month : .year,
                                                      value: -(selectedTimeSpan == .threeMonths ? 3 : 1),
                                                      to: .now)!,
                                unit: .day
                            ), y: .value("Weight", 0))
                            .foregroundStyle(.clear)
                        }
                        ForEach(setsForExercise(withoutZeroWeights: true)) { workoutSet in
                            LineMark(x: .value("Day", workoutSet.setGroup!.workout!.date!, unit: .day),
                                     y: .value("Weight", convertWeightForDisplaying(max(.weight, in: workoutSet))))
                            .foregroundStyle((exercise.muscleGroup?.color ?? .accentColor).gradient)
                            .interpolationMethod(.catmullRom)
                            .symbol {
                                Circle()
                                    .fill((exercise.muscleGroup?.color ?? .accentColor).gradient)
                                    .frame(width: 10)
                            }
                        }
                        .foregroundStyle(exercise.muscleGroup?.color ?? .accentColor)
                        PointMark(x: .value("Day", Date.now),
                                  y: .value("Weight", 0))
                        .foregroundStyle(.clear)
                    }
                    .chartYScale(domain: 0...(personalBest(for: .weight) + 20))
                }
                VStack {
                    Text(NSLocalizedString("repetitions", comment: ""))
                        .font(.body.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Chart {
                        if selectedTimeSpan != .allTime || !firstPerformedOverOneYearAgo {
                            PointMark(x: .value(
                                "Day",
                                Calendar.current.date(byAdding: selectedTimeSpan == .threeMonths ? .month : .year,
                                                      value: -(selectedTimeSpan == .threeMonths ? 3 : 1),
                                                      to: .now)!,
                                unit: .day
                            ), y: .value("Weight", 0))
                            .foregroundStyle(.clear)
                        }
                        ForEach(setsForExercise(withoutZeroWeights: true)) { workoutSet in
                            LineMark(x: .value("Day", workoutSet.setGroup!.workout!.date!, unit: .day),
                                     y: .value("Weight", max(.repetitions, in: workoutSet)))
                            .foregroundStyle((exercise.muscleGroup?.color ?? .accentColor).gradient)
                            .interpolationMethod(.catmullRom)
                            .symbol {
                                Circle()
                                    .fill((exercise.muscleGroup?.color ?? .accentColor).gradient)
                                    .frame(width: 10)
                            }
                        }
                        .foregroundStyle(exercise.muscleGroup?.color ?? .accentColor)
                        PointMark(x: .value("Day", Date.now),
                                  y: .value("Weight", 0))
                        .foregroundStyle(.clear)
                    }
                    .chartYScale(domain: 0...(personalBest(for: .repetitions) + 20))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 180)
            Picker("Calendar Component", selection: $selectedTimeSpan) {
                Text(NSLocalizedString("threeMonths", comment: "")).tag(TimeSpan.threeMonths)
                Text(NSLocalizedString("year", comment: "")).tag(TimeSpan.year)
                Text(NSLocalizedString("all", comment: "")).tag(TimeSpan.allTime)
            }.pickerStyle(.segmented)
                .padding(.top)
        }
    }
    
    private var setGroupList: some View {
        VStack(spacing: SECTION_SPACING) {
            ForEach(groupedWorkoutSetGroups.indices, id:\.self) { index in
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(setGroupGroupHeaderTitle(for: index))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: CELL_SPACING) {
                        ForEach(groupedWorkoutSetGroups[index]) { setGroup in
                            WorkoutSetGroupCell(
                                setGroup: setGroup,
                                focusedIntegerFieldIndex: .constant(nil),
                                sheetType: .constant(nil),
                                isReordering: .constant(false),
                                supplementaryText: "\(setGroup.workout?.date?.description(.short) ?? "")  ·  \(setGroup.workout?.name ?? "")"
                            )
                            .padding(CELL_PADDING)
                            .tileStyle()
                            .canEdit(false)
                        }
                    }
                }
            }
            .emptyPlaceholder(database.getWorkoutSetGroups(with: exercise)) {
                Text(NSLocalizedString("noHistory", comment: ""))
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private func personalBest(for attribute: WorkoutSet.Attribute) -> Int {
        database.getWorkoutSets(with: exercise)
            .map {
                attribute == .repetitions ? max(.repetitions, in: $0) : convertWeightForDisplaying(max(.weight, in: $0))
            }
            .max() ?? 0
    }
    
    private func max(_ attribute: WorkoutSet.Attribute, in workoutSet: WorkoutSet) -> Int {
        if let standardSet = workoutSet as? StandardSet {
            return Int(attribute == .repetitions ? standardSet.repetitions : standardSet.weight)
        }
        if let dropSet = workoutSet as? DropSet {
            return Int((attribute == .repetitions ? dropSet.repetitions : dropSet.weights)?.max() ?? 0)
        }
        if let superSet = workoutSet as? SuperSet {
            if superSet.setGroup?.exercise == exercise {
                return Int(attribute == .repetitions ? superSet.repetitionsFirstExercise : superSet.weightFirstExercise)
            } else {
                return Int(attribute == .repetitions ? superSet.repetitionsSecondExercise : superSet.weightSecondExercise)
            }
        }
        return 0
    }
    
    private var firstPerformedOverOneYearAgo: Bool {
        Calendar.current.date(byAdding: .year, value: -1, to: .now)!
        >
        database.getWorkoutSets(with: exercise).compactMap({ $0.setGroup?.workout?.date }).min() ?? .now
    }
    
    private func setsForExercise(withoutZeroRepetitions: Bool = false, withoutZeroWeights: Bool = false) -> [WorkoutSet] {
        database.getWorkoutSets(with: exercise)
            .filter { !withoutZeroRepetitions || max(.repetitions, in: $0) > 0 }
            .filter { !withoutZeroWeights || max(.weight, in: $0) > 0 }
    }
    
    private var groupedWorkoutSetGroups: [[WorkoutSetGroup]] {
        database.getGroupedWorkoutSetGroups(with: exercise)
    }
    
    private func setGroupGroupHeaderTitle(for index: Int) -> String {
        guard let date = groupedWorkoutSetGroups.value(at: index)?.first?.workout?.date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseDetailScreen(exercise: Database.preview.getExercises().first!)
        }
        .environmentObject(Database.preview)
    }
}
