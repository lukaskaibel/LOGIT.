//
//  AllExercisesView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.03.22.
//

import SwiftUI

struct AllExercisesView: View {
    
    // MARK: - State Objects
    
    @StateObject private var allExercises = AllExercises()
    
    // MARK: - State
    
    @State private var showingAddExercise = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            MuscleGroupSelector(selectedMuscleGroup: $allExercises.selectedMuscleGroup)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            ForEach(allExercises.groupedExercises) { group in
                Section(content: {
                    ForEach(group, id: \.objectID) { exercise in
                        ZStack {
                            ExerciseCell(exercise: exercise)
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.medium))
                                .foregroundColor(exercise.muscleGroup?.color ?? .secondaryLabel)
                                .padding(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: exercise.objectID))) {
                                EmptyView()
                            }.opacity(0)
                        }
                    }.listRowSeparator(.hidden)
                }, header: {
                    Text(allExercises.getLetter(for: group))
                        .sectionHeaderStyle()
                })
            }
        }.listStyle(.plain)
            .searchable(text: $allExercises.searchedText )
            .navigationTitle(NSLocalizedString("exercises", comment: "sports activity"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExercise.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                EditExerciseView(editExercise: EditExercise())
            }
    }
    
}

struct AllExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        AllExercisesView()
    }
}
