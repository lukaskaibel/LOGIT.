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
    
    @Binding var selectedExercise: Exercise?
    @State private var isAddingExercise: Bool = false
    
    init(exerciseSelection: ExerciseSelection, selectedExercise: Binding<Exercise?>) {
        self.exerciseSelection = exerciseSelection
        self._selectedExercise = selectedExercise
    }
    
    var body: some View {
        List {
            MuscleGroupSelector(selectedMuscleGroup: $exerciseSelection.selectedMuscleGroup)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            ForEach(exerciseSelection.groupedExercises) { group in
                ExerciseSection(for: group)
            }
        }.listStyle(.plain)
            .navigationTitle(selectedExercise == nil  ? NSLocalizedString("addExercise", comment: "") : NSLocalizedString("selectExercise", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $exerciseSelection.searchedText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: NSLocalizedString("searchExercises", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingExercise = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .sheet(isPresented: $isAddingExercise, onDismiss: { exerciseSelection.updateView() }) {
                EditExerciseView(editExercise: EditExercise())
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
                            Label("\(NSLocalizedString("delete", comment: "")) \(exercise.name ?? "")", systemImage: "trash")
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
            ExerciseSelectionView(exerciseSelection: ExerciseSelection(), selectedExercise: .constant(Exercise()))
        }
    }
}
