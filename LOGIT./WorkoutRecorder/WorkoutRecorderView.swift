//
//  WorkoutRecorderView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import SwiftUI

struct WorkoutRecorderView: View {
    
    @StateObject private var workoutRecorder = WorkoutRecorder(database: Database.shared)
    @StateObject private var exerciseSelection = ExerciseSelection(context: Database.shared.container.viewContext)
    @Environment(\.dismiss) var dismiss
    
    @State private var showingExerciseSelection = false
    @State private var showingFinishWorkoutAlert = false
    @State private var showingDeleteUnusedSetsAndFinishWorkoutAlert = false
        
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Header
                Divider()
                ExerciseList
            }.environmentObject(workoutRecorder)
            .sheet(isPresented: $showingExerciseSelection, onDismiss: { workoutRecorder.setGroupWithSelectedExercise = nil }) {
                NavigationView {
                    ExerciseSelectionView(exerciseSelection: exerciseSelection,
                                          selectedExercise: Binding(get: { workoutRecorder.setGroupWithSelectedExercise?.exercise }, set: {
                        if let exercise = $0 {
                            if let setGroup = workoutRecorder.setGroupWithSelectedExercise {
                                setGroup.exercise = exercise
                            } else {
                                workoutRecorder.addSetGroup(with: exercise)
                            }
                        }
                    }))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel", role: .cancel) {
                                showingExerciseSelection = false
                            }
                        }
                    }
                }
            }.navigationBarHidden(true)
                .confirmationDialog(Text("Do you want to finish the workout?"),
                                    isPresented: $showingFinishWorkoutAlert,
                                    titleVisibility: .automatic) {
                    Button("Finish Workout") {
                        workoutRecorder.saveWorkout()
                        dismiss()
                    }
                }
                .confirmationDialog(Text("Delete all sets without entries and finish workout?"),
                                    isPresented: $showingDeleteUnusedSetsAndFinishWorkoutAlert,
                                    titleVisibility: .visible) {
                    Button("Delete Sets and Finish Workout", role: .destructive) {
                        workoutRecorder.deleteSetsWithoutRepsAndWeight()
                        print(workoutRecorder.workout.sets)
                        if workoutRecorder.workout.isEmpty {
                            workoutRecorder.deleteWorkout()
                        } else {
                            workoutRecorder.saveWorkout()
                        }
                        dismiss()
                    }
                }
        }
    }
    
    private var workoutDurationString: String {
        "\(workoutRecorder.workoutDuration/3600):\(workoutRecorder.workoutDuration/60 / 10 % 6 )\(workoutRecorder.workoutDuration/60 % 10):\(workoutRecorder.workoutDuration % 60 / 10)\(workoutRecorder.workoutDuration%60 % 10)"
    }
    
    private var Header: some View {
        VStack(spacing: 5) {
            Text(workoutDurationString)
                .foregroundColor(.secondaryLabel)
                .font(.body.monospacedDigit())
            HStack {
                TextField("Workout Title", text: $workoutRecorder.workoutName)
                    .font(.title2.weight(.bold))
                Spacer()
                Button(action: {
                    if workoutRecorder.workoutHasEntries {
                        if workoutRecorder.setsWithoutRepsAndWeight.isEmpty {
                            showingFinishWorkoutAlert.toggle()
                        } else {
                            showingDeleteUnusedSetsAndFinishWorkoutAlert.toggle()
                        }
                    } else {
                        workoutRecorder.deleteWorkout()
                        dismiss()
                    }
                }) {
                    Image(systemName: !workoutRecorder.workoutHasEntries ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(!workoutRecorder.workoutHasEntries ? .fill : .accentColor)
                        .font(.title)
                }
            }
        }.padding(.horizontal)
            .padding(.bottom)
            .background(Color.tertiaryBackground)
    }
    
    
    private var ExerciseList: some View {
        List {
            ForEach(workoutRecorder.setGroups, id:\.objectID) { setGroup in
                VStack {
                    if let index = workoutRecorder.workout.index(of: setGroup) {
                        Text("\(index + 1)/\(workoutRecorder.workout.numberOfSetGroups)")
                            .foregroundColor(.secondaryLabel)
                            .font(.caption)
                    }
                    ExerciseCell(setGroup: setGroup, showingExerciseSelection: $showingExerciseSelection)
                }
            }.padding(.vertical)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            AddExerciseButton
                .padding(.vertical)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }.listStyle(.plain)
            .background(Color.secondaryBackground)
            .onAppear {
                UIScrollView.appearance().keyboardDismissMode = .onDrag
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Copy last Set") {
                        
                    }.foregroundColor(.accentColor)
                        .font(.body.weight(.semibold))
                }
            }
    }
    
    private var AddExerciseButton: some View {
        Button(action: {
            showingExerciseSelection = true
        }) {
            Label("Add Exercise", systemImage: "plus.circle.fill")
                .foregroundColor(.accentColor)
                .font(.body.weight(.bold))
        }.frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(0.2))
            .cornerRadius(15)
    }
    
}

struct WorkoutRecorderListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecorderView()
    }
}
