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
            VStack(alignment: .leading) {
                TextField(NSLocalizedString("exerciseName", comment: ""), text: $editExercise.exerciseName)
                    .font(.body.weight(.medium))
                    .padding()
                    .background(Color.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(NSLocalizedString("exerciseNameDescription", comment: ""))
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                    .padding(.leading)
                Spacer()
            }.padding()
                .navigationTitle(editExercise.exerciseToEdit != nil ? "\(NSLocalizedString("edit", comment: "")) \(editExercise.exerciseName)" : NSLocalizedString("newExercise", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(NSLocalizedString("cancel", comment: "")) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(editExercise.exerciseToEdit != nil ? NSLocalizedString("update", comment: "") : NSLocalizedString("save", comment: "")) {
                            if editExercise.exerciseExistsWithName(editExercise.exerciseName) {
                                showingExerciseExistsAlert = true
                            } else if editExercise.exerciseName.trimmingCharacters(in: .whitespaces).isEmpty {
                                showingExerciseNameEmptyAlert = true
                            } else {
                                editExercise.saveName()
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
