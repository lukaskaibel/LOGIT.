//
//  ExerciseSelectionView.swift
//  LOGIT
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
            ForEach(exerciseSelection.groupedExercises) { group in
                ExerciseSection(for: group)
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
    
    @ViewBuilder
    private func ExerciseSection(for group: [Exercise]) -> some View {
        Section(content: {
            ForEach(group, id:\.objectID) { exercise in
                HStack {
                    Text(exercise.name ?? "No Name")
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExercise = exercise
                            dismiss()
                        }
                    Spacer()
                    if selectedExercise == exercise {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3.weight(.semibold))
                    }
                    Menu(content: {
                        Button(role: .destructive, action: {
                            exerciseSelection.delete(exercise: exercise)
                        }) {
                            Label("Delete \(exercise.name ?? "")", systemImage: "trash")
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .padding(8)
                            .contentShape(Rectangle())
                    }.foregroundColor(.label)
                }.padding(.vertical, 8)
            }
        }, header: {
            Text(exerciseSelection.getLetter(for: group).uppercased())
        })
    }
    
}

struct ExerciseSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseSelectionView(exerciseSelection: ExerciseSelection(context: Database.preview.container.viewContext), selectedExercise: .constant(Exercise()))
        }
    }
}
