//
//  AllExercisesView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.03.22.
//

import SwiftUI

struct AllExercisesView: View {
    
    @StateObject private var allExercises = AllExercises()
    
    @State private var showingAddExercise = false
    
    var body: some View {
        List {
            ForEach(allExercises.groupedExercises) { group in
                Section(content: {
                    ForEach(group, id: \.objectID) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: exercise.objectID))) {
                            Text(exercise.name ?? "")
                                .font(.body.weight(.semibold))
                                .lineLimit(1)
                                .padding(.vertical, 8)
                        }
                    }
                }, header: {
                    Text(allExercises.getLetter(for: group))
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
