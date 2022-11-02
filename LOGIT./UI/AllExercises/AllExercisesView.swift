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
        List {
            MuscleGroupSelector(selectedMuscleGroup: $selectedMuscleGroup)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            ForEach(database.getGroupedExercises(withNameIncluding: searchedText,
                                                 for: selectedMuscleGroup)) { group in
                Section(content: {
                    ForEach(group, id: \.objectID) { exercise in
                        ZStack {
                            ExerciseCell(exercise: exercise)
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.medium))
                                .foregroundColor(exercise.muscleGroup?.color ?? .secondaryLabel)
                                .padding(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                EmptyView()
                            }.opacity(0)
                        }
                    }.listRowSeparator(.hidden)
                }, header: {
                    Text(getLetter(for: group))
                        .sectionHeaderStyle()
                })
            }
        }.listStyle(.plain)
            .searchable(text: $searchedText )
            .navigationTitle(NSLocalizedString("exercises", comment: "sports activity"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExercise.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                EditExerciseView()
            }
    }
    
    // MARK: - Supporting Functions
    
    func getLetter(for group: [Exercise]) -> String {
        String(group.first?.name?.first ?? Character(" "))
    }
    
}

struct AllExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        AllExercisesView()
    }
}
