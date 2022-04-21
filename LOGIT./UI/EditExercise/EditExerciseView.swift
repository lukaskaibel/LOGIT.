//
//  EditExerciseView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.03.22.
//

import SwiftUI

struct EditExerciseView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var editExercise: EditExercise
    
    @State private var showingExerciseExistsAlert: Bool = false
    @State private var showingExerciseNameEmptyAlert: Bool = false
        
    var body: some View {
        NavigationView {
            List {
                Section(content: {
                    TextField(NSLocalizedString("exerciseName", comment: ""),
                              text: $editExercise.exerciseName)
                        .font(.body.weight(.semibold))
                        .padding(.vertical, 3)
                }, footer: {
                    Text(NSLocalizedString("exerciseNameDescription", comment: ""))
                })
                Section(content: {
                    Picker(NSLocalizedString("muscleGroup", comment: ""),
                           selection: $editExercise.muscleGroup) {
                        ForEach(MuscleGroup.allCases) { muscleGroup in
                            Text(muscleGroup.description).tag(muscleGroup)
                        }
                    }
                })
            }.listStyle(.insetGrouped)
                .navigationTitle(editExercise.isEditingExistingExercise ? "\(NSLocalizedString("edit", comment: "")) \(editExercise.exerciseName)" : NSLocalizedString("newExercise", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(NSLocalizedString("cancel", comment: "")) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(NSLocalizedString("done", comment: "")) {
                            if editExercise.nameIsEmpty() {
                                showingExerciseNameEmptyAlert = true
                            } else if editExercise.exerciseAlreadyExists() && !editExercise.isEditingExistingExercise {
                                showingExerciseExistsAlert = true
                            } else {
                                editExercise.save()
                                dismiss()
                            }
                        }.font(.body.weight(.semibold))
                    }
                }
                .alert("\(editExercise.exerciseName.trimmingCharacters(in: .whitespaces)) \(NSLocalizedString("alreadyExists", comment: ""))", isPresented: $showingExerciseExistsAlert) {
                    Button(NSLocalizedString("ok", comment: "")) {
                        showingExerciseExistsAlert = false
                    }
                }
                .alert(NSLocalizedString("nameCantBeEmpty", comment: ""), isPresented: $showingExerciseNameEmptyAlert) {
                    Button(NSLocalizedString("ok", comment: "")) {
                        showingExerciseNameEmptyAlert = false
                    }
                }
        }
    }
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(editExercise: EditExercise())
    }
}
