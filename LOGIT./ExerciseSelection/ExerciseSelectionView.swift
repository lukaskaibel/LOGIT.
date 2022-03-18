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
    @StateObject private var exerciseSelection: ExerciseSelection
    
    @Binding var selectedExercise: Exercise?
    @State private var isAddingExercise: Bool = false
    
    init(exerciseSelection: StateObject<ExerciseSelection>, selectedExercise: Binding<Exercise?>) {
        self._exerciseSelection = exerciseSelection
        self._selectedExercise = selectedExercise
    }
    
    var body: some View {
        List {
            ForEach(exerciseSelection.exercises) { exercise in
                HStack {
                    Text(exercise.name ?? "No Name")
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
            }.onDelete { indexSet in
                exerciseSelection.deleteExercise(for: indexSet)
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
            .sheet(isPresented: $isAddingExercise) {
                AddingExerciseView(exerciseSelection: exerciseSelection)
            }
    }
    
    private struct AddingExerciseView: View {
        
        @Environment(\.dismiss) var dismiss
        
        enum FocusField: Hashable {
            case field
        }

        @FocusState private var focusedField: FocusField?
        
        @ObservedObject var exerciseSelection: ExerciseSelection
        @State private var newExerciseName: String = ""
        @State private var showingExerciseExistsAlert: Bool = false
        @State private var showingExerciseNameEmptyAlert: Bool = false
        
        var body: some View {
            NavigationView {
                VStack(alignment: .leading) {
                    TextField("Exercise Name", text: $newExerciseName)
                        .font(.body.weight(.medium))
                        .padding()
                        .background(Color.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .focused($focusedField, equals: .field)
                        .task { focusedField = .field }
                    Text("Enter the name for the new exercise.")
                        .foregroundColor(.secondaryLabel)
                        .font(.caption)
                        .padding(.leading)
                    Spacer()
                }.padding()
                    .navigationTitle("New Exercise")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                if exerciseSelection.exerciseExistsWithName(newExerciseName) {
                                    showingExerciseExistsAlert = true
                                } else if newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty {
                                    showingExerciseNameEmptyAlert = true
                                } else {
                                    exerciseSelection.addExerciseWith(name: newExerciseName)
                                    dismiss()
                                }
                            }.font(.body.weight(.semibold))
                        }
                    }
                    .alert("\(newExerciseName.trimmingCharacters(in: .whitespaces)) already exists.", isPresented: $showingExerciseExistsAlert) {
                        Button("Ok") {
                            showingExerciseExistsAlert = false
                        }
                    }
                    .alert("Name can't be empty.", isPresented: $showingExerciseNameEmptyAlert) {
                        Button("Ok") {
                            showingExerciseNameEmptyAlert = false
                        }
                    }
            }
        }
        
    }
    
}

struct ExerciseSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseSelectionView(exerciseSelection: StateObject(wrappedValue: ExerciseSelection(context: Database.preview.container.viewContext)), selectedExercise: .constant(Exercise()))
        }
    }
}
