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
                TextField("Exercise Name", text: $editExercise.exerciseName)
                    .font(.body.weight(.medium))
                    .padding()
                    .background(Color.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("Enter the name for the exercise.")
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                    .padding(.leading)
                Spacer()
            }.padding()
                .navigationTitle(editExercise.exerciseToEdit != nil ? "Edit \(editExercise.exerciseName)" : "New Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(editExercise.exerciseToEdit != nil ? "Update" : "Save") {
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
                .alert("\(editExercise.exerciseName.trimmingCharacters(in: .whitespaces)) already exists.", isPresented: $showingExerciseExistsAlert) {
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

struct EditExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        EditExerciseView(editExercise: EditExercise())
    }
}
