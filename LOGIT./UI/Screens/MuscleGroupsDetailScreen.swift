//
//  MuscleGroupsDetailScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.11.22.
//

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
                    Text(NSLocalizedString("muscleGroups", comment: ""))
                        .screenHeaderStyle()
                    Text(NSLocalizedString("lastTenWorkouts", comment: ""))
                        .screenHeaderSecondaryStyle()
                        .foregroundColor(.secondaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                PieGraph(
                    items: muscleGroupOccurances.map {
                        PieGraph.Item(
                            title: $0.0.description,
                            amount: $0.1,
                            color: $0.0.color,
                            isSelected: $0.0 == selectedMuscleGroup
                        )
                    },
                    centerView: centerView,
                    hideLegend: true
                )
                .frame(height: 200)
                .padding()
                .padding(.vertical, 50)

                MuscleGroupSelector(selectedMuscleGroup: $selectedMuscleGroup)

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

    private var filteredSetGroups: [WorkoutSetGroup] {
        setGroups.filter {
            $0.exercise?.muscleGroup == selectedMuscleGroup
                || $0.secondaryExercise?.muscleGroup == selectedMuscleGroup
        }
    }

    private var sets: [WorkoutSet] {
        (setGroups.map { $0.sets }).reduce([], +)
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

struct MuscleGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MuscleGroupsDetailScreen(setGroups: Database.preview.testWorkout.setGroups)
        }
        .environmentObject(Database.preview)
    }
}
