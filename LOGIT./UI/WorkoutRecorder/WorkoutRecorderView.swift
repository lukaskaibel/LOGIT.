//
//  WorkoutRecorderView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 24.02.22.
//

import SwiftUI
import CoreData

struct WorkoutRecorderView: View {
    
    @StateObject private var workoutRecorder = WorkoutRecorder(database: Database.shared)
    @StateObject private var exerciseSelection = ExerciseSelection(context: Database.shared.container.viewContext)
    @StateObject private var exerciseDetail = ExerciseDetail(context: Database.shared.container.viewContext, exerciseID: NSManagedObjectID())
    @Environment(\.dismiss) var dismiss
    
    @State private var showingExerciseSelection = false
    @State private var showingFinishWorkoutAlert = false
    @State private var showingDeleteUnusedSetsAndFinishWorkoutAlert = false
    @State private var showingDiscardWorkoutAlert = false
        
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
            }
            .sheet(isPresented: workoutRecorder.showingExerciseDetail) {
                NavigationView {
                    ExerciseDetailView(exerciseDetail: exerciseDetail.with(exercise: workoutRecorder.exerciseForExerciseDetail!))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Dismiss") { workoutRecorder.showingExerciseDetail.wrappedValue = false }
                            }
                        }
                }
            }
            .navigationBarHidden(true)
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
                    if workoutRecorder.workout.isEmpty {
                        workoutRecorder.deleteWorkout()
                    } else {
                        workoutRecorder.saveWorkout()
                    }
                    dismiss()
                }
            }
            .confirmationDialog(Text("This workout has to entries. Discard it?"),
                                isPresented: $showingDiscardWorkoutAlert,
                                titleVisibility: .visible) {
                Button("Discard Workout", role: .destructive) {
                    workoutRecorder.deleteSetsWithoutRepsAndWeight()
                    workoutRecorder.deleteWorkout()
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
                TextField(Workout.getStandardName(for: Date()), text: $workoutRecorder.workoutName)
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
                        .foregroundColor(!workoutRecorder.workoutHasEntries ? .fill : .accentColor)
                        .font(.title)
                }
            }
        }.padding(.horizontal)
            .padding(.bottom)
            .background(Color.tertiaryBackground)
    }
    
    @State private var animationValue = 1.0
    
    private var ExerciseList: some View {
        List {
            ForEach(workoutRecorder.setGroups, id:\.objectID) { setGroup in
                Section {
                    ExerciseHeader(setGroup: setGroup)
                    ForEach(setGroup.sets?.array as? [WorkoutSet] ?? .emptyList, id:\.objectID) { workoutSet in
                        WorkoutSetCell(workoutSet: workoutSet)
                    }.onDelete { indexSet in
                        workoutRecorder.delete(setsWithIndices: indexSet, in: setGroup)
                    }
                    Button(action: {
                        workoutRecorder.addSet(to: setGroup)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Label("Add Set", systemImage: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.body.weight(.bold))
                    }.padding(15)
                        .frame(maxWidth: .infinity)
                }.transition(.slide)
                    .buttonStyle(.plain)
            }.listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            AddExerciseButton
                .padding(.vertical)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.bottom, 20 )
        }.listStyle(.insetGrouped)
            .background(Color.secondaryBackground)
            .onAppear {
                UIScrollView.appearance().keyboardDismissMode = .onDrag
            }
            
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
                            .font(.title3.weight(.semibold))
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondaryLabel)
                            .font(.caption.weight(.semibold))
                    }
                }
                Spacer()
                Menu(content: {
                    Section {
                        Button(action: {
                            workoutRecorder.exerciseForExerciseDetail = setGroup.exercise
                        }) {
                            Label("Show \(setGroup.exercise?.name ?? "")", systemImage: "info.circle")
                        }
                    }
                    Section {
                        Button(role: .destructive, action: {
                            withAnimation {
                                workoutRecorder.delete(setGroup: setGroup)
                            }
                        }) {
                            Label("Remove", systemImage: "xmark.circle")
                        }
                    }
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.label)
                        .padding(7)
                }
            }.padding()
            Divider()
                .padding(.leading)
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
            TextField("0", text: repetitionsString)
                .keyboardType(.numberPad)
                .foregroundColor(.accentColor)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(7)
                .background(workoutSet.repetitions == 0 ? .secondaryBackground : Color.accentColor.opacity(0.1))
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
            TextField("0", text: weightString)
                .keyboardType(.numberPad)
                .foregroundColor(.accentColor)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .padding(7)
                .background(workoutSet.weight == 0 ? .secondaryBackground : Color.accentColor.opacity(0.1))
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
        }.padding(.trailing)
    }
    
    
    private var AddExerciseButton: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
