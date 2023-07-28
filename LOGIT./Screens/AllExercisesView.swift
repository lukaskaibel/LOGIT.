//
//  AllExercisesView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.03.22.
//

import SwiftUI

struct AllExercisesView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var searchedText = ""
    @State private var selectedMuscleGroup: MuscleGroup? = nil
    @State private var showingAddExercise = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: SECTION_SPACING) {
                MuscleGroupSelector(selectedMuscleGroup: $selectedMuscleGroup)
                ForEach(groupedExercises) { group in
                    VStack(spacing: SECTION_HEADER_SPACING) {
                        Text(getLetter(for: group))
                            .sectionHeaderStyle2()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(spacing: CELL_SPACING) {
                            ForEach(group, id: \.objectID) { exercise in
                                NavigationLink(value: exercise) {
                                    HStack {
                                        ExerciseCell(exercise: exercise)
                                        Spacer()
                                        NavigationChevron()
                                            .foregroundColor(exercise.muscleGroup?.color ?? .secondaryLabel)
                                    }
                                    .padding(CELL_PADDING)
                                    .tileStyle()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .emptyPlaceholder(groupedExercises) {
                    Text(NSLocalizedString("noExercises", comment: ""))
                }
            }
        }
        .searchable(text: $searchedText )
        .navigationTitle(NSLocalizedString("exercises", comment: "sports activity"))
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Exercise.self) { selectedExercise in
            ExerciseDetailView(exercise: selectedExercise)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddExercise.toggle() }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            EditExerciseView(initialMuscleGroup: selectedMuscleGroup ?? .chest)
        }
    }
    
    // MARK: - Methods / Computed Properties
    
    var groupedExercises: [[Exercise]] {
        database.getGroupedExercises(withNameIncluding: searchedText,
                                     for: selectedMuscleGroup)
    }
    
    func getLetter(for group: [Exercise]) -> String {
        String(group.first?.name?.first ?? Character(" "))
    }
    
}

struct AllExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AllExercisesView()
        }
        .environmentObject(Database.preview)
    }
}
