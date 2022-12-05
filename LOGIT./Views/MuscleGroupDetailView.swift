//
//  MuscleGroupDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.11.22.
//

import SwiftUI

struct MuscleGroupDetailView: View {
    
    // MARK: - Parameters
    
    let setGroups: [WorkoutSetGroup]
    
    // MARK: - State
    
    @State private var selectedMuscleGroup: MuscleGroup? = nil
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("muscleGroups", comment: ""))
                        .font(.largeTitle.weight(.bold))
                    Text(NSLocalizedString("lastTenWorkouts", comment: ""))
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .foregroundColor(.secondaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                PieGraph(items: muscleGroupOccurances.map { PieGraph.Item(title: $0.0.description,
                                                                          amount: $0.1,
                                                                          color: $0.0.color) },
                         hideLegend: true)
                .frame(height: 200)
                .padding()
                HStack {
                    Grid(verticalSpacing: 5) {
                        ForEach(0..<((muscleGroupOccurances.count+1)/3), id:\.self) { index in
                            GridRow {
                                HStack {
                                    titleUnitView(forOccuranceAtIndex: index * 3)
                                    if muscleGroupOccurances.indices.contains(index * 3 + 1) {
                                        Spacer()
                                        titleUnitView(forOccuranceAtIndex: index * 3 + 1)
                                    }
                                    if muscleGroupOccurances.indices.contains(index * 3 + 2) {
                                        Spacer()
                                        titleUnitView(forOccuranceAtIndex: index * 3 + 2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            ForEach(filteredSetGroups, id:\.objectID) { setGroup in
                SetGroupDetailView(setGroup: setGroup,
                                   supplementaryText: "\(setGroup.workout!.date!.description(.short))  ·  \(setGroup.workout!.name!)")
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            .emptyPlaceholder(filteredSetGroups) {
                Text(NSLocalizedString("noExercises", comment: ""))
            }
            Spacer(minLength: 30)
                .listRowBackground(Color.clear)
        }
        .offset(y: -30)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Supporting Views
    
    private func titleUnitView(forOccuranceAtIndex index: Int) -> some View {
        let muscleGroup = muscleGroupOccurances[index].0
        let isSelected = muscleGroup == selectedMuscleGroup
        
        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            selectedMuscleGroup = selectedMuscleGroup == muscleGroup ? nil : muscleGroupOccurances[index].0
        } label: {
            TitleUnitView(title: muscleGroup.description,
                          value: String(Int(round(Float(muscleGroupOccurances[index].1) / Float(muscleGroupOccurances.map(\.1).reduce(0, +))*100))),
                          unit: "%")
            .foregroundColor(isSelected ? .white : muscleGroup.color)
            .padding(CELL_PADDING)
            .frame(maxWidth: 150)
            .background(isSelected ? muscleGroup.color : muscleGroup.color.secondaryTranslucentBackground)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var filteredSetGroups: [WorkoutSetGroup] {
        setGroups.filter { $0.exercise?.muscleGroup == selectedMuscleGroup || $0.secondaryExercise?.muscleGroup == selectedMuscleGroup }
    }
    
    private var sets: [WorkoutSet] {
        (setGroups.map { $0.sets }).reduce([], +)
    }
    
    private var muscleGroupOccurances: [(MuscleGroup, Int)] {
        Array(sets
            .reduce(into: [MuscleGroup:Int]()) {
                if let muscleGroup = $1.setGroup?.exercise?.muscleGroup {
                    $0[muscleGroup, default: 0] += 1
                }
                if let muscleGroup = $1.setGroup?.secondaryExercise?.muscleGroup {
                    $0[muscleGroup, default: 0] += 1
                }
            }
            .merging(allMuscleGroupZeroDict, uniquingKeysWith: +)
        ).sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    private var allMuscleGroupZeroDict: [MuscleGroup:Int] {
        MuscleGroup.allCases.reduce(into: [MuscleGroup:Int](), { $0[$1, default: 0] = 0 })
    }
    
}

struct MuscleGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MuscleGroupDetailView(setGroups: Database.preview.testWorkout.setGroups)
            .environmentObject(Database.preview)
    }
}
