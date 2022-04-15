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
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @StateObject private var workoutRecorder = WorkoutRecorder(database: Database.shared)
    @StateObject private var exerciseSelection = ExerciseSelection(context: Database.shared.container.viewContext)
    @StateObject private var exerciseDetail = ExerciseDetail(context: Database.shared.container.viewContext, exerciseID: NSManagedObjectID())
    
    @State private var showingStartScreen = true
    @State private var editMode: EditMode = .inactive
    @State private var isEditing: Bool = false
    @State private var showingExerciseSelection = false
    @State private var showingTimerView = false
    @State private var showingFinishWorkoutAlert = false
    @State private var showingDeleteUnusedSetsAndFinishWorkoutAlert = false
    @State private var showingDiscardWorkoutAlert = false
        
    var body: some View {
        NavigationView {
            if showingStartScreen {
                WorkoutRecorderStartScreen(showingStartScreen: $showingStartScreen)
                    .environmentObject(workoutRecorder)
            } else {
                RecorderView
            }
        }
    }
    
    private var RecorderView: some View {
        VStack(spacing: 0) {
            Header
            Divider()
            ExerciseList
        }.environmentObject(workoutRecorder)
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: { showingTimerView.toggle() }) {
                        TimerTimeView(showingTimerView: $showingTimerView)
                    }
                        .font(.body.monospacedDigit())
                    Spacer()
                    Button(isEditing ? NSLocalizedString("done", comment: "") : NSLocalizedString("reorderExercises", comment: "")) {
                        isEditing.toggle()
                        editMode = isEditing ? .active : .inactive
                    }.disabled(workoutRecorder.workout.numberOfSetGroups == 0)
                }
            }
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
        .navigationBarHidden(true)
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
                workoutRecorder.deleteSetsWithoutRepsAndWeight()
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
                workoutRecorder.deleteSetsWithoutRepsAndWeight()
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
                    if workoutRecorder.workoutHasEntries {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        if workoutRecorder.setsWithoutRepsAndWeight.isEmpty {
                            showingFinishWorkoutAlert.toggle()
                        } else {
                            showingDeleteUnusedSetsAndFinishWorkoutAlert.toggle()
                        }
                    } else {
                        showingDiscardWorkoutAlert.toggle()
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
            ForEach(workoutRecorder.workout.setGroups?.array as? [WorkoutSetGroup] ?? .emptyList, id:\.objectID) { setGroup in
                // Neccessary because onMode crashes with Sections
                if isEditing {
                    ReorderExerciseCell(for: setGroup)
                } else {
                    ExerciseWithSetsSection(for: setGroup)
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
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(NSLocalizedString("done", comment: "")) {
                            hideKeyboard()
                        }.font(.body.weight(.semibold))
                    }
                }
            }
            
    }
    
    private func ExerciseWithSetsSection(for setGroup: WorkoutSetGroup) -> some View {
        Section {
            ExerciseHeader(setGroup: setGroup)
                .deleteDisabled(true)
            ForEach(setGroup.sets?.array as? [WorkoutSet] ?? .emptyList, id:\.objectID) { workoutSet in
                WorkoutSetCell(workoutSet: workoutSet)
            }.onDelete { indexSet in
                workoutRecorder.delete(setsWithIndices: indexSet, in: setGroup)
            }
            Button(action: {
                workoutRecorder.addSet(to: setGroup)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }) {
                Label(NSLocalizedString("addSet", comment: ""), systemImage: "plus.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.bold))
            }.padding(15)
                .frame(maxWidth: .infinity)
                .deleteDisabled(true)
        }.transition(.slide)
            .buttonStyle(.plain)
    }
    
    private func ReorderExerciseCell(for setGroup: WorkoutSetGroup) -> some View {
        ExerciseHeader(setGroup: setGroup)
    }
    
    @ViewBuilder
    private func ExerciseHeader(setGroup: WorkoutSetGroup) -> some View {
        VStack(spacing: 0) {
            EmptyView()
                .frame(height: 1)
            HStack {
                Button(action: {
                    workoutRecorder.setGroupWithSelectedExercise = setGroup
                    showingExerciseSelection = true
                }) {
                    HStack(spacing: 3) {
                        Text(setGroup.exercise?.name ?? "No Name")
                            .foregroundColor(.label)
                            .font(.title3.weight(.semibold))
                            .lineLimit(1)
                        if !isEditing {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondaryLabel)
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
                Spacer()
                if !isEditing {
                    Menu(content: {
                        Section {
                            Button(action: {
                                workoutRecorder.exerciseForExerciseDetail = setGroup.exercise
                            }) {
                                Label(NSLocalizedString("showDetails", comment: ""), systemImage: "info.circle")
                            }
                        }
                        Section {
                            Button(role: .destructive, action: {
                                withAnimation {
                                    workoutRecorder.delete(setGroup: setGroup)
                                }
                            }) {
                                Label(NSLocalizedString("remove", comment: ""), systemImage: "xmark.circle")
                            }
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.label)
                            .padding(7)
                    }
                }
            }.padding()
            if !isEditing {
                Divider()
                    .padding(.leading)
                    .padding(.bottom, 5)
            }
        }
    }
    
    private func WorkoutSetCell(workoutSet: WorkoutSet) -> some View {
        var repetitionsString: Binding<String> {
            Binding<String>(
                get: { workoutSet.repetitions == 0 ? "" : String(workoutSet.repetitions) },
                set: {
                    value in workoutSet.repetitions = NumberFormatter().number(from: value)?.int64Value ?? 0
                    workoutRecorder.updateView()
                }
            )
        }
        
        var weightString: Binding<String> {
            Binding<String>(
                get: { workoutSet.weight == 0 ? "" : String(convertWeightForDisplaying(workoutSet.weight)) },
                set: {
                    value in workoutSet.weight = convertWeightForStoring(NumberFormatter().number(from: value)?.int64Value ?? 0)
                    workoutRecorder.updateView()
                }
            )
        }
        
        return HStack {
            Text(String((workoutRecorder.indexInSetGroup(for: workoutSet) ?? 0) + 1))
                .foregroundColor(.secondaryLabel)
                .font(.body.monospacedDigit())
                .padding()
            TextField(workoutRecorder.repetitionsPlaceholder(for: workoutSet), text: repetitionsString)
                .keyboardType(.numberPad)
                .foregroundColor(.accentColor)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(7)
                .background(workoutSet.repetitions == 0 ? (colorScheme == .light ? Color.secondaryBackground : .background) : .accentColorBackground)
                .cornerRadius(5)
                .overlay {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(workoutSet.repetitions == 0 ? .secondaryLabel : .accentColor)
                            .font(.caption.weight(.bold))
                            .padding(7)
                        Spacer()
                    }
                }
            TextField(workoutRecorder.weightPlaceholder(for: workoutSet), text: weightString)
                .keyboardType(.numberPad)
                .foregroundColor(.accentColor)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(7)
                .background(workoutSet.weight == 0 ? (colorScheme == .light ? Color.secondaryBackground : .background) : .accentColorBackground)
                .cornerRadius(5)
                .overlay {
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(workoutSet.weight == 0 ? .secondaryLabel : .accentColor)
                            .font(.caption.weight(.bold))
                            .padding(7)
                        Spacer()
                    }
                }
            if let templateSet = workoutRecorder.templateSet(for: workoutSet), templateSet.hasEntry {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    if workoutSet.hasEntry {
                        workoutSet.clearEntries()
                    } else {
                        workoutSet.match(templateSet)
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundColor(workoutSet.hasEntry ? .accentColor : .secondaryLabel)
                        .padding(7)
                        .background(workoutSet.hasEntry ? Color.accentColorBackground : .secondaryBackground)
                        .cornerRadius(5)
                }
            }
        }.padding(.trailing)
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
        WorkoutRecorderView()
    }
}
