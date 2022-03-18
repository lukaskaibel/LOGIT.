//
//  ExerciseSelectionView.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 11.12.21.
//

import SwiftUI
import CoreData

struct ExerciseSelectionView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var exerciseSelection: ExerciseSelection
    @StateObject private var editExercise: EditExercise = EditExercise()
    
    @Binding var selectedExercise: Exercise?
    @State private var isAddingExercise: Bool = false
    
    init(exerciseSelection: ExerciseSelection, selectedExercise: Binding<Exercise?>) {
        self.exerciseSelection = exerciseSelection
        self._selectedExercise = selectedExercise
    }
    
    var body: some View {
        List {
            ForEach(exerciseSelection.exercises) { exercise in
                HStack {
                    Text(exercise.name ?? "No Name")
                        .lineLimit(1)
                    Spacer()
                    if selectedExercise == exercise {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.body.weight(.semibold))
                    }
                }.padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedExercise = exercise
                        dismiss()
                    }
            }
        }.listStyle(.plain)
            .navigationTitle(selectedExercise == nil  ? "Add Exercise" : "Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $exerciseSelection.searchedText, prompt: "Search in Exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingExercise = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .sheet(isPresented: $isAddingExercise, onDismiss: { exerciseSelection.updateExercises() }) {
                EditExerciseView(editExercise: editExercise)
            }
    }
    
}

struct ExerciseSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseSelectionView(exerciseSelection: ExerciseSelection(context: Database.preview.container.viewContext), selectedExercise: .constant(Exercise()))
        }
    }
}
