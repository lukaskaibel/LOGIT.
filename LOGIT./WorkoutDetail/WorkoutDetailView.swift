//
//  WorkoutDetailView.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var workoutDetail: WorkoutDetail
    @FocusState private var textFieldFocused: Bool
    @State private var isShowingDeleteWorkoutAlert: Bool = false
    
    var body: some View {
        List {
            ForEach(workoutDetail.setGroups) { setGroup in
                Section(content: {
                    VStack(spacing: 0) {
                        Divider()
                        ForEach(setGroup.sets?.array as? [WorkoutSet] ?? .emptyList, id:\.objectID) { workoutSet in
                            HStack {
                                Text(String((setGroup.index(of: workoutSet) ?? 0) + 1))
                                    .font(.body.monospacedDigit())
                                    .foregroundColor(.secondaryLabel)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 0) {
                                    EmptyView()
                                        .frame(height: 1)
                                    WorkoutSetCell(workoutSet: workoutSet,
                                                   selectedSet: $workoutDetail.selectedSet,
                                                   selectedAttribute: $workoutDetail.selectedAttribute,
                                                   textFieldFocused: _textFieldFocused)
                                        .padding(.vertical, 8)
                                    Divider()
                                }
                            }
                        }
                    }.listRowSeparator(.hidden)
                }, header: {
                    Header(for: setGroup)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }, footer: {
                    Text("\(setGroup.numberOfSets) sets")
                        .foregroundColor(.secondaryLabel)
                        .font(.subheadline)
                        .listRowSeparator(.hidden, edges: .bottom)
                })
            }
            Footer
        }.listStyle(.plain)
        .navigationTitle(workoutDetail.workout.name ?? "No Name")
        .navigationBarTitleDisplayMode(.inline)
        .background {
            TextField("Empty Field", text: $workoutDetail.textFieldString)
                .keyboardType(.numberPad)
                .opacity(0)
                .focused($textFieldFocused, equals: true)
        }
        .gesture (
            TapGesture()
                .onEnded {
                    workoutDetail.selectedSet = nil
                    workoutDetail.selectedAttribute = nil
                }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: {
                    isShowingDeleteWorkoutAlert = true
                }) {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("Deleting Workout", isPresented: $isShowingDeleteWorkoutAlert) {
            Button("Delete Workout", role: .destructive) {
                workoutDetail.deleteWorkout()
                dismiss()
            }
        }
        
    }
        
    //MARK: - Supporting Views
    
    @ViewBuilder
    private func Header(for setGroup: WorkoutSetGroup) -> some View {
        HStack {
            if let exercise = setGroup.exercise {
                NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(context: Database.shared.container.viewContext, exerciseID: exercise.objectID))) {
                    HStack {
                        Text("\((workoutDetail.workout.index(of: setGroup) ?? 0) + 1).")
                            .foregroundColor(.secondaryLabel)
                            .font(.title2)
                        Text("\(exercise.name ?? "No Name")")
                            .foregroundColor(.label)
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.leading)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.separator)
                            .font(.caption.weight(.semibold))
                    }
                }
                Spacer()
            }
        }.padding(.horizontal)
    }
    
    @ViewBuilder
    private var Footer: some View {
        HStack {
            Spacer()
            VStack {
                Text(workoutDetail.workoutDateString)
                Text("\(workoutDetail.workout.numberOfSetGroups) Exercises")
            }.foregroundColor(.secondaryLabel)
                .font(.subheadline)
            Spacer()
        }.listRowSeparator(.hidden)
            .padding(.vertical, 50)
    }
    
    struct WorkoutSetCell: View {
        
        @ObservedObject var workoutSet: WorkoutSet
        @Binding var selectedSet: WorkoutSet?
        @Binding var selectedAttribute: WorkoutSet.Attribute?
        @FocusState var textFieldFocused: Bool
        
        var body: some View {
            HStack {
                if workoutSet.repetitions > 0 {
                    UnitView(value: String(workoutSet.repetitions), unit: "RPS")
                        .foregroundColor(isSelected && selectedAttribute == .repetitions ? .blue : .label)
                        .padding(.vertical, 5)
                        .padding(.trailing, 8)
                        .background(isSelected && selectedAttribute == .repetitions ? Color.secondaryBackground : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay {
                            if isSelected && selectedAttribute == .repetitions {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.blue, lineWidth: 2)
                            }
                        }
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    selectedSet = workoutSet
                                    selectedAttribute = .repetitions
                                    textFieldFocused = true
                                }
                        )
                } else {
                    UnitView(value: "", unit: "") //needed in order for cell not to collapse if reps and weight = 0
                        .padding(.vertical, 5)
                }
                if workoutSet.weight > 0 {
                    if workoutSet.repetitions > 0 {
                        dividerCircle
                    }
                    UnitView(value: String(convertWeightForDisplaying(workoutSet.weight)), unit: WeightUnit.used.rawValue.uppercased())
                        .foregroundColor(isSelected && selectedAttribute == .weight ? .blue : .label)
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    selectedSet = workoutSet
                                    selectedAttribute = .weight
                                    textFieldFocused = true
                                }
                        )
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(isSelected && selectedAttribute == .weight ? Color.secondaryBackground : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay {
                            if isSelected && selectedAttribute == .weight {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.blue, lineWidth: 2)
                            }
                        }
                }
                if workoutSet.time > 0 {
                    if workoutSet.repetitions > 0 || workoutSet.weight > 0 {
                        dividerCircle
                    }
                    UnitView(value: String(workoutSet.time), unit: "SEC")
                        .foregroundColor(isSelected && selectedAttribute == .time ? .blue : .label)
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    selectedSet = workoutSet
                                    selectedAttribute = .time
                                    textFieldFocused = true
                                }
                        )
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(isSelected && selectedAttribute == .time ? Color.secondaryBackground : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay {
                            if isSelected && selectedAttribute == .time {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.blue, lineWidth: 2)
                            }
                        }
                }
            }
                
        }
        
        var isSelected: Bool { workoutSet == selectedSet }
        
        var dividerCircle: some View {
            Circle()
                .foregroundColor(.separator)
                .frame(width: 4, height: 4)
        }
        
    }
    
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(workoutDetail: WorkoutDetail(context: Database.shared.container.viewContext, workoutID: NSManagedObjectID()))
    }
}
