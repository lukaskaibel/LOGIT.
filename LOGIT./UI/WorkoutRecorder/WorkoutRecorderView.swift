//
//  WorkoutRecorderView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import SwiftUI
import UIKit
import CoreData

struct WorkoutRecorderView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    // MARK: - State Objects
    
    @StateObject internal var workoutRecorder = WorkoutRecorder()
    @StateObject private var exerciseSelection = ExerciseSelection()
    @StateObject private var exerciseDetail = ExerciseDetail(exerciseID: NSManagedObjectID())
    
    // MARK: - State
    
    @State internal var isEditing: Bool = false
    @State internal var showingExerciseSelection = false
    @State private var showingStartScreen = true
    @State private var editMode: EditMode = .inactive
    @State private var showingTimerView = false
    @State private var showingFinishWorkoutAlert = false
    @State private var showingDeleteUnusedSetsAndFinishWorkoutAlert = false
    @State private var showingDiscardWorkoutAlert = false
    
    // MARK: - Init
    
    init(template: TemplateWorkout?) {
        if let template = template {
            workoutRecorder.updateWorkout(with: template)
        }
    }
        
    var body: some View {
        NavigationView {
            RecorderView
        }.environmentObject(workoutRecorder)
    }
    
    private var RecorderView: some View {
        VStack(spacing: 0) {
            Header
            Divider()
            ExerciseList
        }.environment(\.editMode, $editMode)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: { showingTimerView.toggle() }) {
                        TimerTimeView(showingTimerView: $showingTimerView)
                    }.font(.body.monospacedDigit())
                    Spacer()
                    Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("reorderExercises", comment: "")) {
                        isEditing.toggle()
                        editMode = isEditing ? .active : .inactive
                    }.disabled(workoutRecorder.workout.numberOfSetGroups == 0)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(NSLocalizedString("done", comment: "")) {
                            hideKeyboard()
                        }.font(.body.weight(.semibold))
                    }
                }
            }
            .sheet(isPresented: $showingExerciseSelection, onDismiss: { workoutRecorder.setGroupWithSelectedExercise = nil; workoutRecorder.isSelectingSecondaryExercise = false }) {
                NavigationView {
                    ExerciseSelectionView(exerciseSelection: exerciseSelection,
                                          selectedExercise: Binding(get: {
                        guard let setGroup = workoutRecorder.setGroupWithSelectedExercise else { return nil }
                        return workoutRecorder.isSelectingSecondaryExercise ? setGroup.secondaryExercise : setGroup.exercise
                    }, set: {
                        guard let exercise = $0 else { return }
                        guard let setGroup = workoutRecorder.setGroupWithSelectedExercise else { workoutRecorder.addSetGroup(with: exercise); return }
                        if workoutRecorder.isSelectingSecondaryExercise {
                            setGroup.secondaryExercise = exercise
                        } else {
                            setGroup.exercise = exercise
                        }
                    }))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                                showingExerciseSelection = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: workoutRecorder.showingExerciseDetail) {
                NavigationView {
                    ExerciseDetailView(exerciseDetail: exerciseDetail.with(exercise: workoutRecorder.exerciseForExerciseDetail!))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("dismiss", comment: "")) { workoutRecorder.showingExerciseDetail.wrappedValue = false }
                            }
                        }
                }
            }
            .confirmationDialog(Text(NSLocalizedString("finishWorkoutConfimation", comment: "")),
                                isPresented: $showingFinishWorkoutAlert,
                                titleVisibility: .automatic) {
                Button(NSLocalizedString("finishWorkout", comment: "")) {
                    workoutRecorder.saveWorkout()
                    dismiss()
                }.font(.body.weight(.semibold))
            }
            .confirmationDialog(Text(NSLocalizedString("deleteSetsWithoutEntries", comment: "")),
                                isPresented: $showingDeleteUnusedSetsAndFinishWorkoutAlert,
                                titleVisibility: .visible) {
                Button(NSLocalizedString("deleteSets", comment: ""), role: .destructive) {
                    workoutRecorder.deleteSetsWithoutEntries()
                    if workoutRecorder.workout.isEmpty {
                        workoutRecorder.deleteWorkout()
                    } else {
                        workoutRecorder.saveWorkout()
                    }
                    dismiss()
                }
            }
            .confirmationDialog(Text(NSLocalizedString("noEntriesConfirmation", comment: "")),
                                isPresented: $showingDiscardWorkoutAlert,
                                titleVisibility: .visible) {
                Button(NSLocalizedString("discardWorkout", comment: ""), role: .destructive) {
                    workoutRecorder.deleteSetsWithoutEntries()
                    workoutRecorder.deleteWorkout()
                    dismiss()
                }
            }
    }
        
    private var Header: some View {
        VStack(spacing: 5) {
            WorkoutDurationView()
            HStack {
                TextField(Workout.getStandardName(for: Date()), text: $workoutRecorder.workoutName)
                    .foregroundColor(.label)
                    .font(.title2.weight(.bold))
                Spacer()
                Button(action: {
                    guard workoutRecorder.workoutHasEntries else { showingDiscardWorkoutAlert.toggle(); return }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    if workoutRecorder.setsWithoutEntries.isEmpty {
                        showingFinishWorkoutAlert.toggle()
                    } else {
                        showingDeleteUnusedSetsAndFinishWorkoutAlert.toggle()
                    }
                }) {
                    Image(systemName: !workoutRecorder.workoutHasEntries ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(!workoutRecorder.workoutHasEntries ? .separator : .accentColor)
                        .font(.title)
                }
            }
        }.padding(.horizontal)
            .padding(.bottom)
            .background(colorScheme == .light ? Color.tertiaryBackground : .secondaryBackground)
    }
    
    @State private var animationValue = 1.0
    
    private var ExerciseList: some View {
        List {
            ForEach(workoutRecorder.workout.setGroups, id:\.objectID) { setGroup in
                // Neccessary because onMode crashes with Sections
                if isEditing {
                    ReorderSetGroupCell(for: setGroup)
                } else {
                    SetGroupCell(for: setGroup)
                }
            }.onMove(perform: workoutRecorder.moveSetGroups)
                .onDelete { indexSet in workoutRecorder.delete(setGroupsWithIndexes: indexSet) }
                .listRowSeparator(.hidden)
                .listRowBackground(colorScheme == .light ? Color.tertiaryBackground : .secondaryBackground)
                .listRowInsets(EdgeInsets())
            if !isEditing {
                AddExerciseButton
                    .padding(.vertical)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.bottom, 20 )
            }
        }.listStyle(.insetGrouped)
            .onAppear {
                UIScrollView.appearance().keyboardDismissMode = .interactive
            }
            
    }
        
    private func ReorderSetGroupCell(for setGroup: WorkoutSetGroup) -> some View {
        ExerciseHeader(setGroup: setGroup)
    }
    
    
    private var AddExerciseButton: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            showingExerciseSelection = true
        }) {
            Label(NSLocalizedString("addExercise", comment: ""), systemImage: "plus.circle.fill")
                .foregroundColor(.accentColor)
                .font(.body.weight(.bold))
        }.frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColorBackground)
            .cornerRadius(15)
    }
    
}

struct WorkoutRecorderListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecorderView(template: Database.preview.testTemplate)
    }
}
