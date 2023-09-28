//
//  ExerciseDetailScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.01.22.
//

import Charts
import CoreData
import SwiftUI

struct ExerciseDetailScreen: View {

    enum TimeSpan {
        case threeMonths, year, allTime
    }

    // MARK: - Environment

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    @EnvironmentObject var overviewController: WidgetController

    // MARK: - State

    @State private var selectedTimeSpanForWeight: DateLineChart.DateDomain = .threeMonths
    @State private var selectedTimeSpanForRepetitions: DateLineChart.DateDomain = .threeMonths
    @State private var selectedTimeSpanForVolume: DateLineChart.DateDomain = .threeMonths
    @State private var selectedTimeSpanForSetsPerWeek: DateLineChart.DateDomain = .threeMonths
    @State private var showDeletionAlert = false
    @State private var showingEditExercise = false

    // MARK: - Variables

    let exercise: Exercise

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                header
                    .padding(.horizontal)

                WidgetCollectionView(
                    title: NSLocalizedString("overview", comment: ""),
                    collection: overviewController.exerciseDetailWidgetCollection
                ) { item in
                    Group {
                        switch item.type {
                        case .personalBest: exerciseInfo
                        case .bestWeightPerDay: weightGraph
                        case .bestRepetitionsPerDay: repetitionsGraph
                        case .volumePerDay: volumePerDayGraph
                        default: EmptyView()
                        }
                    }
                }
                .padding(.horizontal)

                setGroupList
                    .padding(.horizontal)
            }
            .animation(.easeInOut)
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(exercise.muscleGroup?.color ?? .accentColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(
                        action: { showingEditExercise.toggle() },
                        label: {
                            Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                        }
                    )
                    Button(
                        role: .destructive,
                        action: { showDeletionAlert.toggle() },
                        label: {
                            Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                        }
                    )
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            Text(NSLocalizedString("deleteExerciseConfirmation", comment: "")),
            isPresented: $showDeletionAlert,
            titleVisibility: .visible
        ) {
            Button(
                "\(NSLocalizedString("delete", comment: ""))",
                role: .destructive,
                action: {
                    database.delete(exercise, saveContext: true)
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showingEditExercise) {
            ExerciseEditScreen(exerciseToEdit: exercise)
        }
    }

    // MARK: - Supporting Views

    private var header: some View {
        VStack(alignment: .leading) {
            Text(exercise.name ?? "")
                .screenHeaderStyle()
                .lineLimit(2)
            Text(exercise.muscleGroup?.description.capitalized ?? "")
                .screenHeaderSecondaryStyle()
                .foregroundStyle((exercise.muscleGroup?.color ?? .clear).gradient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    //    private var overviewViewItems: Binding<[WidgetCollectionView.Item<AnyView>]> {
    //        Binding(
    //            get: {
    //                (overviewController.exerciseDetailWidgetCollection?.items ?? [])!
    //                    .compactMap { overviewItem -> WidgetCollectionView.Item<AnyView>? in
    //                        if overviewItem.id == OverviewController.ExerciseDetailItems.personalBest.rawValue {
    //                            return WidgetCollectionView.Item<AnyView>(
    //                                id: overviewItem.id!,
    //                                name: NSLocalizedString(overviewItem.id!, comment: ""),
    //                                content: AnyView(exerciseInfo),
    //                                isAdded: overviewItem.isAdded
    //                            )
    //                        }
    //                        return nil
    //                    }
    //            },
    //            set: { newValue in
    //                newValue
    //                    .
    //
    //            }
    //        )
    //
    //    }

    private var exerciseInfo: some View {
        VStack {
            Text(NSLocalizedString("personalBest", comment: ""))
                .tileHeaderStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("repetitions", comment: ""))
                    UnitView(
                        value: String(personalBest(for: .repetitions)),
                        unit: NSLocalizedString("rps", comment: "")
                    )
                    .foregroundStyle((exercise.muscleGroup?.color ?? .label).gradient)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("weight", comment: ""))
                    UnitView(
                        value: String(personalBest(for: .weight)),
                        unit: WeightUnit.used.rawValue.capitalized
                    )
                    .foregroundStyle((exercise.muscleGroup?.color ?? .label).gradient)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }

    private var weightGraph: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("weight", comment: ""))
                    .tileHeaderStyle()
                Text(NSLocalizedString("bestPerDay", comment: ""))
                    .tileHeaderSecondaryStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateLineChart(dateDomain: selectedTimeSpanForWeight) {
                setsForExercise(withHeighest: .weight, withoutZeroWeights: true)
                    .map {
                        .init(
                            date: $0.setGroup!.workout!.date!,
                            value: convertWeightForDisplaying($0.max(.weight))
                        )
                    }
            }
            .foregroundStyle((exercise.muscleGroup?.color.gradient)!)
            Picker("Calendar Component", selection: $selectedTimeSpanForWeight) {
                Text(NSLocalizedString("threeMonths", comment: ""))
                    .tag(DateLineChart.DateDomain.threeMonths)
                Text(NSLocalizedString("year", comment: "")).tag(DateLineChart.DateDomain.year)
                Text(NSLocalizedString("all", comment: "")).tag(DateLineChart.DateDomain.allTime)
            }
            .pickerStyle(.segmented)
            .padding(.top)
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }

    private var repetitionsGraph: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("repetitions", comment: ""))
                    .tileHeaderStyle()
                Text(NSLocalizedString("bestPerDay", comment: ""))
                    .tileHeaderSecondaryStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateLineChart(dateDomain: selectedTimeSpanForRepetitions) {
                setsForExercise(withHeighest: .repetitions, withoutZeroWeights: true)
                    .map {
                        .init(
                            date: $0.setGroup!.workout!.date!,
                            value: $0.max(.repetitions)
                        )
                    }
            }
            .foregroundStyle((exercise.muscleGroup?.color.gradient)!)
            Picker("Calendar Component", selection: $selectedTimeSpanForRepetitions) {
                Text(NSLocalizedString("threeMonths", comment: ""))
                    .tag(DateLineChart.DateDomain.threeMonths)
                Text(NSLocalizedString("year", comment: "")).tag(DateLineChart.DateDomain.year)
                Text(NSLocalizedString("all", comment: "")).tag(DateLineChart.DateDomain.allTime)
            }
            .pickerStyle(.segmented)
            .padding(.top)
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }
    
    private var volumePerDayGraph: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(NSLocalizedString("volume", comment: ""))
                    .tileHeaderStyle()
                Text(NSLocalizedString("perDay", comment: ""))
                    .tileHeaderSecondaryStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            DateLineChart(dateDomain: selectedTimeSpanForVolume) {
                volume(for: exercise, per: .day)
                    .map {
                        return .init(
                            date: $0.0,
                            value: $0.1
                        )
                    }
            }
            .foregroundStyle((exercise.muscleGroup?.color.gradient)!)
            Picker("Calendar Component", selection: $selectedTimeSpanForVolume) {
                Text(NSLocalizedString("threeMonths", comment: ""))
                    .tag(DateLineChart.DateDomain.threeMonths)
                Text(NSLocalizedString("year", comment: "")).tag(DateLineChart.DateDomain.year)
                Text(NSLocalizedString("all", comment: "")).tag(DateLineChart.DateDomain.allTime)
            }
            .pickerStyle(.segmented)
            .padding(.top)
        }
        .padding(CELL_PADDING)
        .tileStyle()
    }

    private var setGroupList: some View {
        VStack(spacing: SECTION_SPACING) {
            ForEach(groupedWorkoutSetGroups.indices, id: \.self) { index in
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
                                supplementaryText:
                                    "\(setGroup.workout?.date?.description(.short) ?? "")  ·  \(setGroup.workout?.name ?? "")"
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
                attribute == .repetitions
                    ? $0.max(.repetitions) : convertWeightForDisplaying($0.max(.weight))
            }
            .max() ?? 0
    }

    private func max(_ attribute: WorkoutSet.Attribute, in workoutSet: WorkoutSet) -> Int {
        if let standardSet = workoutSet as? StandardSet {
            return Int(attribute == .repetitions ? standardSet.repetitions : standardSet.weight)
        }
        if let dropSet = workoutSet as? DropSet {
            return Int(
                (attribute == .repetitions ? dropSet.repetitions : dropSet.weights)?.max() ?? 0
            )
        }
        if let superSet = workoutSet as? SuperSet {
            if superSet.setGroup?.exercise == exercise {
                return Int(
                    attribute == .repetitions
                        ? superSet.repetitionsFirstExercise : superSet.weightFirstExercise
                )
            } else {
                return Int(
                    attribute == .repetitions
                        ? superSet.repetitionsSecondExercise : superSet.weightSecondExercise
                )
            }
        }
        return 0
    }

    private var firstPerformedOverOneYearAgo: Bool {
        Calendar.current.date(byAdding: .year, value: -1, to: .now)!
            > database.getWorkoutSets(with: exercise).compactMap({ $0.setGroup?.workout?.date })
            .min()
            ?? .now
    }

    private func setsForExercise(
        withHeighest attribute: WorkoutSet.Attribute,
        withoutZeroRepetitions: Bool = false,
        withoutZeroWeights: Bool = false
    ) -> [WorkoutSet] {
        database.getWorkoutSets(with: exercise, onlyHighest: attribute, in: .day)
            .filter { !withoutZeroRepetitions || $0.max(.repetitions) > 0 }
            .filter { !withoutZeroWeights || $0.max(.weight) > 0 }
    }

    private var groupedWorkoutSetGroups: [[WorkoutSetGroup]] {
        database.getGroupedWorkoutSetGroups(with: exercise)
    }

    private func setGroupGroupHeaderTitle(for index: Int) -> String {
        guard let date = groupedWorkoutSetGroups.value(at: index)?.first?.workout?.date else {
            return ""
        }
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
        .environmentObject(WidgetController.preview)
    }
}
