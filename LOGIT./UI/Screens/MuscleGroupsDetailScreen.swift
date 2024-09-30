//
//  MuscleGroupsDetailScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.11.22.
//

import Charts
import SwiftUI

struct MuscleGroupsDetailScreen: View {

    // MARK: - Parameters

    let setGroups: [WorkoutSetGroup]

    // MARK: - State

    @State private var selectedMuscleGroup: MuscleGroup? = nil

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: SECTION_SPACING) {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("muscleGroupSplit", comment: ""))
                        .screenHeaderStyle()
                    Text(NSLocalizedString("lastTenWorkouts", comment: ""))
                        .screenHeaderSecondaryStyle()
                        .foregroundColor(.secondaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                if #available(iOS 17.0, *) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(NSLocalizedString("overall", comment: ""))
                            Text("Your training programs overall muscle group split")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Chart {
                            ForEach(muscleGroupOccurances, id:\.0) { muscleGroupOccurance in
                                SectorMark(
                                    angle: .value("Value", muscleGroupOccurance.1),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 1
                                )
                                .foregroundStyle(foregroundStyle(for: muscleGroupOccurance.0))
                            }
                        }
                        .frame(width: 100, height: 100)
                    }
                    .padding(CELL_PADDING)
                    .tileStyle()
                    .padding(.horizontal)
                    HStack {
                        if let selectedMuscleGroup = selectedMuscleGroup {
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text(NSLocalizedString("exercises", comment: ""))
                                    Text("\(filteredSetGroups.count)")
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                        .fontWeight(.bold)
                                        .foregroundStyle(selectedMuscleGroup.color.gradient)
                                }
                                Divider()
                                VStack(alignment: .leading) {
                                    Text(NSLocalizedString("sets", comment: ""))
                                    Text("\(filteredSetGroups.flatMap({ $0.sets }).count)")
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                        .fontWeight(.bold)
                                        .foregroundStyle(selectedMuscleGroup.color.gradient)
                                }
                                Divider()
                                VStack(alignment: .leading) {
                                    Text(NSLocalizedString("volume", comment: ""))
                                    UnitView(value: "\(convertWeightForDisplaying(volume(for: selectedMuscleGroup, in: filteredSetGroups.flatMap({ $0.sets }))))", unit: WeightUnit.used.rawValue)
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                        .fontWeight(.bold)
                                        .foregroundStyle(selectedMuscleGroup.color.gradient)
                                }
                            }
                            .padding(.leading)
                            Spacer()
                        }
                        Chart {
                            ForEach(muscleGroupOccurances, id:\.0) { muscleGroupOccurance in
                                SectorMark(
                                    angle: .value("Value", muscleGroupOccurance.1),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 1
                                )
                                .foregroundStyle(foregroundStyle(for: muscleGroupOccurance.0))
                            }
                        }
                        .animation(nil, value: UUID())
                        .frame(width: 200, height: 200)
                        .padding()
                        .padding(.vertical, 50)
                    }
                    .frame(minHeight: 200)
                    .padding(.horizontal)
                }
                
                MuscleGroupSelector(selectedMuscleGroup: $selectedMuscleGroup, withAnimation: true)

                VStack(spacing: CELL_SPACING) {
                    ForEach(filteredSetGroups, id: \.objectID) { setGroup in
                        WorkoutSetGroupCell(
                            setGroup: setGroup,
                            focusedIntegerFieldIndex: .constant(nil),
                            sheetType: .constant(nil),
                            isReordering: .constant(false),
                            supplementaryText:
                                "\(setGroup.workout!.date!.description(.short))  ·  \(setGroup.workout!.name!)"
                        )
                        .canEdit(false)
                        .padding(CELL_PADDING)
                        .tileStyle()
                    }
                    .emptyPlaceholder(filteredSetGroups) {
                        Text(NSLocalizedString("noExercises", comment: ""))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Supporting Views

    private func titleUnitView(forOccuranceAtIndex index: Int) -> some View {
        let muscleGroup = muscleGroupOccurances[index].0
        let isSelected = muscleGroup == selectedMuscleGroup

        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            selectedMuscleGroup =
                selectedMuscleGroup == muscleGroup ? nil : muscleGroupOccurances[index].0
        } label: {
            TitleUnitView(
                title: muscleGroup.description,
                value: String(
                    Int(
                        round(
                            Float(muscleGroupOccurances[index].1)
                                / Float(muscleGroupOccurances.map(\.1).reduce(0, +)) * 100
                        )
                    )
                ),
                unit: "%"
            )
            .foregroundColor(isSelected ? .white : muscleGroup.color)
            .padding(CELL_PADDING)
            .frame(maxWidth: 150)
            .background(
                isSelected ? muscleGroup.color : muscleGroup.color.secondaryTranslucentBackground
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var centerView: some View {
        let numberOfSetsForSelectedMuscleGroup =
            (muscleGroupOccurances.filter { $0.0 == selectedMuscleGroup }).first?.1
            ?? setGroups.reduce(0, { $0 + $1.sets.count })

        return VStack {
            Text(String(numberOfSetsForSelectedMuscleGroup))
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(
                    selectedMuscleGroup?.color
                        .opacity(
                            numberOfSetsForSelectedMuscleGroup == 0 ? 0.7 : 1.0
                        )
                        .gradient ?? Color.label.gradient
                )
            Text(
                NSLocalizedString(
                    "set\(numberOfSetsForSelectedMuscleGroup == 1 ? "" : "s")",
                    comment: ""
                )
            )
            .fontWeight(.medium)
            .foregroundColor(.secondaryLabel)
        }
    }

    // MARK: - Computed Properties
    
    private func foregroundStyle(for muscleGroup: MuscleGroup) -> some ShapeStyle {
        if selectedMuscleGroup == nil || muscleGroup == selectedMuscleGroup {
            return AnyShapeStyle(muscleGroup.color.gradient)
        } else {
            return AnyShapeStyle(muscleGroup.color.secondaryTranslucentBackground)
        }
    }

    private var filteredSetGroups: [WorkoutSetGroup] {
        setGroups.filter {
            $0.exercise?.muscleGroup == selectedMuscleGroup
                || $0.secondaryExercise?.muscleGroup == selectedMuscleGroup
        }
    }

    private var sets: [WorkoutSet] {
        (setGroups.map { $0.sets }).reduce([], +)
    }
    
    private func volume(for muscleGroup: MuscleGroup, in sets: [WorkoutSet]) -> Int {
        sets.reduce(0, { currentVolume, currentSet in
            if let standardSet = currentSet as? StandardSet {
                guard standardSet.exercise?.muscleGroup == muscleGroup else { return 0 }
                return Int(standardSet.repetitions * standardSet.weight)
            }
            if let dropSet = currentSet as? DropSet, let repetitions = dropSet.repetitions, let weights = dropSet.weights {
                guard dropSet.exercise?.muscleGroup == muscleGroup else { return 0 }
                return Int(zip(repetitions, weights).map(*).reduce(0, +))
            }
            if let superSet = currentSet as? SuperSet {
                if superSet.exercise?.muscleGroup == muscleGroup {
                    return Int(superSet.repetitionsFirstExercise * superSet.weightFirstExercise)
                }
                if superSet.secondaryExercise?.muscleGroup == muscleGroup {
                    return Int(superSet.repetitionsSecondExercise * superSet.weightSecondExercise)
                }
            }
            return 0
        })
    }

    private var muscleGroupOccurances: [(MuscleGroup, Int)] {
        Array(
            sets
                .reduce(into: [MuscleGroup: Int]()) {
                    if let muscleGroup = $1.setGroup?.exercise?.muscleGroup {
                        $0[muscleGroup, default: 0] += 1
                    }
                    if let muscleGroup = $1.setGroup?.secondaryExercise?.muscleGroup {
                        $0[muscleGroup, default: 0] += 1
                    }
                }
                .merging(allMuscleGroupZeroDict, uniquingKeysWith: +)
        )
        .sorted {
            MuscleGroup.allCases.firstIndex(of: $0.key)! < MuscleGroup.allCases.firstIndex(
                of: $1.key
            )!
        }
    }

    private var allMuscleGroupZeroDict: [MuscleGroup: Int] {
        MuscleGroup.allCases.reduce(into: [MuscleGroup: Int](), { $0[$1, default: 0] = 0 })
    }

}

private struct PreviewWrapperView: View {
    @EnvironmentObject private var database: Database
    
    var body: some View {
        NavigationView {
            MuscleGroupsDetailScreen(setGroups: database.testWorkout.setGroups)
        }
    }
}

struct MuscleGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .previewEnvironmentObjects()
    }
}
