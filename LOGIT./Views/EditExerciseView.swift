//
//  EditExerciseView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 18.03.22.
//

import SwiftUI

struct EditExerciseView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var exerciseName: String
    @State private var muscleGroup: MuscleGroup
    @State private var showingExerciseExistsAlert: Bool = false
    @State private var showingExerciseNameEmptyAlert: Bool = false
    
    // MARK: - Variables
    
    private let exerciseToEdit: Exercise?
    
    // MARK: - Init
    
    init(exerciseToEdit: Exercise? = nil) {
        self.exerciseToEdit = exerciseToEdit
        _exerciseName = State(initialValue: exerciseToEdit?.name ?? "")
        _muscleGroup = State(initialValue: exerciseToEdit?.muscleGroup ?? .chest)
    }
    
    // MARK: - Body
        
    var body: some View {
        NavigationStack {
            List {
                Section(content: {
                    HStack {
                        ColorMeter(items: [ColorMeter.Item(color: muscleGroup.color,
                                                           amount: 1)])
                        TextField(NSLocalizedString("exerciseName", comment: ""),
                                  text: $exerciseName)
                            .font(.body.weight(.semibold))
                            .padding(.vertical, 5)
                    }
                    .padding(CELL_PADDING)
                }, footer: {
                    Text(NSLocalizedString("exerciseNameDescription", comment: ""))
                }).listRowInsets(EdgeInsets())
                Section(content: {
                    Picker(NSLocalizedString("muscleGroup", comment: ""),
                           selection: $muscleGroup) {
                        ForEach(MuscleGroup.allCases) { muscleGroup in
                            Text(muscleGroup.description).tag(muscleGroup)
                                .foregroundColor(muscleGroup.color)
                        }
                    }
                    .accentColor(muscleGroup.color)
                })
            }.listStyle(.insetGrouped)
                .navigationTitle(exerciseToEdit != nil ? "\(NSLocalizedString("edit", comment: "")) \(exerciseName)" : NSLocalizedString("newExercise", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(NSLocalizedString("cancel", comment: "")) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(NSLocalizedString("done", comment: "")) {
                            if exerciseName.trimmingCharacters(in: .whitespaces).isEmpty {
                                showingExerciseNameEmptyAlert = true
                            } else if exerciseToEdit == nil && !database.getExercises(withNameIncluding: exerciseName).isEmpty {
                                showingExerciseExistsAlert = true
                            } else {
                                saveExercise()
                                dismiss()
                            }
                        }.font(.body.weight(.semibold))
                    }
                }
                .alert("\(exerciseName.trimmingCharacters(in: .whitespaces)) \(NSLocalizedString("alreadyExists", comment: ""))", isPresented: $showingExerciseExistsAlert) {
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
    
    // MARK: - Computed Properties
    
    private func saveExercise() {
        if let exerciseToEdit = exerciseToEdit {
            exerciseToEdit.name = exerciseName
            exerciseToEdit.muscleGroup = muscleGroup
        } else {
            database.newExercise(name: exerciseName, muscleGroup: muscleGroup)
        }
        database.save()
    }
    
}

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView()
    }
}
