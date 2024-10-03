//
//  MuscleGroupsDetailScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.11.22.
//

import Charts
import OSLog
import SwiftUI

struct MuscleGroupSplitScreen: View {
    
    // MARK: - Static
    
    private static let logger = Logger(
        subsystem: ".com.lukaskbl.LOGIT",
        category: "MuscleGroupSplitScreen"
    )
    
    // MARK: - Environment
    
    @EnvironmentObject private var workoutRepository: WorkoutRepository
    @EnvironmentObject private var muscleGroupService: MuscleGroupService

    // MARK: - State

    @State private var selectedMuscleGroup: MuscleGroup? = nil
    @State private var selectedWeeksFromNow: Int = 0

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: SECTION_SPACING) {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("muscleGroupSplit", comment: ""))
                        .screenHeaderStyle()
                    Text(NSLocalizedString("PerWeek", comment: ""))
                         .screenHeaderSecondaryStyle()
                         .foregroundColor(.secondaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                if #available(iOS 17.0, *) {
                    HStack {
                        Text(Calendar.current.date(byAdding: .weekOfYear, value: -selectedWeeksFromNow, to: .now)?.startOfWeek.weekDescription ?? "")
                        Spacer()
                        HStack {
                            Button {
                                withAnimation {
                                    selectedWeeksFromNow = selectedWeeksFromNow < 54 ? selectedWeeksFromNow + 1 : 0
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                            .disabled(selectedWeeksFromNow >= 54)
                            Button {
                                withAnimation {
                                    selectedWeeksFromNow = selectedWeeksFromNow > 0 ? selectedWeeksFromNow - 1 : 0
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                            }
                            .disabled(selectedWeeksFromNow == 0)
                        }
                    }
                    .font(.title3)
                    .padding(.horizontal)
                    
                    TabView(selection: $selectedWeeksFromNow) {
                        ForEach(Array<Int>(0..<54).reversed(), id:\.self) { weeksFromNow in
                            let workoutsInWeek = getWorkouts(inWeeksFromNow: weeksFromNow)
                            HStack {
                                if let selectedMuscleGroup = selectedMuscleGroup {
                                    let setGroupsInWeekForSelectedMuscleGroup = getSetGroups(
                                        with: selectedMuscleGroup,
                                        from: workoutsInWeek
                                    
                                    )
                                    VStack(alignment: .leading, spacing: 10) {
                                        VStack(alignment: .leading) {
                                            Text(NSLocalizedString("exercises", comment: ""))
                                            Text("\(setGroupsInWeekForSelectedMuscleGroup.count)")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.bold)
                                                .foregroundStyle(selectedMuscleGroup.color.gradient)
                                        }
                                        Divider()
                                        VStack(alignment: .leading) {
                                            Text(NSLocalizedString("sets", comment: ""))
                                            Text("\(setGroupsInWeekForSelectedMuscleGroup.flatMap({ $0.sets }).count)")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.bold)
                                                .foregroundStyle(selectedMuscleGroup.color.gradient)
                                        }
                                        Divider()
                                        VStack(alignment: .leading) {
                                            Text(NSLocalizedString("volume", comment: ""))
                                            UnitView(value: "\(convertWeightForDisplaying(volume(for: selectedMuscleGroup, in: setGroupsInWeekForSelectedMuscleGroup.flatMap({ $0.sets }))))", unit: WeightUnit.used.rawValue)
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.bold)
                                                .foregroundStyle(selectedMuscleGroup.color.gradient)
                                        }
                                    }
                                    .padding(.leading)
                                    Spacer()
                                }
                                
                                let muscleGroupOccurances = muscleGroupService.getMuscleGroupOccurances(
                                    in: getWorkouts(
                                        inWeeksFromNow: weeksFromNow
                                    )
                                )
                                MuscleGroupOccurancesChart(
                                    muscleGroupOccurances: muscleGroupOccurances,
                                    selectedMuscleGroup: selectedMuscleGroup
                                )
                                .animation(nil, value: UUID())
                                .frame(width: 200, height: 200)
                                .padding()
                                .padding(.vertical, 50)
                            }
                            .frame(minHeight: 200)
                            .padding(.horizontal)
                            .tag(weeksFromNow)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(minHeight: 300)
                }
                
                MuscleGroupSelector(
                    selectedMuscleGroup: $selectedMuscleGroup,
                    from: muscleGroupsInSelectedWeek,
                    withAnimation: true
                )

                let workoutsInSelectedWeek = getWorkouts(inWeeksFromNow: selectedWeeksFromNow)
                let setGroupsInSelectedWeekWithSelectedMuscleGroup = selectedMuscleGroup == nil ? Array(workoutsInSelectedWeek.map({ $0.setGroups }).joined()) : getSetGroups(
                    with: selectedMuscleGroup!,
                    from: workoutsInSelectedWeek
                )
                VStack(spacing: CELL_SPACING) {
                    ForEach(
                        setGroupsInSelectedWeekWithSelectedMuscleGroup,
                        id: \.objectID
                    ) { setGroup in
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
                    .emptyPlaceholder(setGroupsInSelectedWeekWithSelectedMuscleGroup) {
                        Text(NSLocalizedString("noWorkoutsInWeek", comment: ""))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
        }
        .onChange(of: selectedWeeksFromNow) { _ in
            selectedMuscleGroup = muscleGroupsInSelectedWeek.contains(where: { $0 == selectedMuscleGroup }) ? selectedMuscleGroup : nil
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Computed Properties
    
    private func foregroundStyle(for muscleGroup: MuscleGroup) -> some ShapeStyle {
        if selectedMuscleGroup == nil || muscleGroup == selectedMuscleGroup {
            return AnyShapeStyle(muscleGroup.color.gradient)
        } else {
            return AnyShapeStyle(muscleGroup.color.secondaryTranslucentBackground)
        }
    }
    
    private func getWorkouts(inWeeksFromNow weeksFromNow: Int) -> [Workout] {
        guard let weeksFromNowDate = Calendar.current.date(
            byAdding: .weekOfYear,
            value: -weeksFromNow,
            to: .now
        ) else {
            Self.logger.warning("weeksFromNowDate could not be created.")
            return []
        }
        let workoutsInWeek = workoutRepository.getWorkouts(
            for: [.weekOfYear, .yearForWeekOfYear],
            including: weeksFromNowDate
        )
        return workoutsInWeek
    }
    
    private func getSetGroups(with muscleGroup: MuscleGroup, from workouts: [Workout]) -> [WorkoutSetGroup] {
        workouts
            .map({ $0.setGroups })
            .joined()
            .filter({ $0.exercise?.muscleGroup == selectedMuscleGroup
                || $0.secondaryExercise?.muscleGroup == selectedMuscleGroup })
    }
    
    private func volume(for muscleGroup: MuscleGroup, in sets: [WorkoutSet]) -> Int {
        sets.reduce(0, { currentVolume, currentSet in
            if let standardSet = currentSet as? StandardSet {
                guard standardSet.exercise?.muscleGroup == muscleGroup else { return currentVolume }
                return currentVolume + Int(standardSet.repetitions * standardSet.weight)
            }
            if let dropSet = currentSet as? DropSet, let repetitions = dropSet.repetitions, let weights = dropSet.weights {
                guard dropSet.exercise?.muscleGroup == muscleGroup else { return currentVolume }
                return currentVolume + Int(zip(repetitions, weights).map(*).reduce(0, +))
            }
            if let superSet = currentSet as? SuperSet {
                var volumeForFirstExercise = 0
                var volumeForSecondExercise = 0
                if superSet.exercise?.muscleGroup == muscleGroup {
                    volumeForFirstExercise = Int(superSet.repetitionsFirstExercise * superSet.weightFirstExercise)
                }
                if superSet.secondaryExercise?.muscleGroup == muscleGroup {
                    volumeForSecondExercise = Int(superSet.repetitionsSecondExercise * superSet.weightSecondExercise)
                }
                return currentVolume + volumeForFirstExercise + volumeForSecondExercise
            }
            return currentVolume
        })
    }

    private var muscleGroupsInSelectedWeek: [MuscleGroup] {
        muscleGroupService.getMuscleGroupOccurances(in: getWorkouts(inWeeksFromNow: selectedWeeksFromNow))
            .map({ $0.0 })
    }
    
    

}

private struct PreviewWrapperView: View {
    var body: some View {
        NavigationView {
            MuscleGroupSplitScreen()
        }
    }
}

struct MuscleGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .previewEnvironmentObjects()
    }
}
