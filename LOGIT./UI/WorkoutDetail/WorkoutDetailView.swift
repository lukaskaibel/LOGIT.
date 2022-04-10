//
//  WorkoutDetailView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var canNavigateToTemplate: Bool
    
    @StateObject var workoutDetail: WorkoutDetail
    @State private var isShowingDeleteWorkoutAlert: Bool = false
    @State private var isShowingNewTemplate: Bool = false
    @State private var isShowingTemplateDetail: Bool = false
    
    var body: some View {
        List {
            if canNavigateToTemplate {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 1)
                    .listRowSeparator(.hidden)
                TemplateView
                    .buttonStyle(PlainButtonStyle())
            }
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
                                    WorkoutSetCell(workoutSet: workoutSet)
                                        .padding(.vertical, 8)
                                    Divider()
                                }
                            }
                        }
                    }.listRowSeparator(.hidden)
                }, header: {
                    Header(for: setGroup)
                        .listRowInsets(EdgeInsets())
                }, footer: {
                    Text("\(setGroup.numberOfSets) set\(setGroup.numberOfSets == 1 ? "" : "s")")
                        .foregroundColor(.secondaryLabel)
                        .font(.subheadline)
                        .listRowSeparator(.hidden, edges: .bottom)
                }).padding(.leading)
            }.listRowInsets(EdgeInsets())
            Footer
        }.listStyle(.plain)
            .navigationTitle(workoutDetail.workout.name ?? "No Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive, action: {
                        isShowingDeleteWorkoutAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .confirmationDialog("Delete \(workoutDetail.workout.name ?? "Workout")? This action cannot be undone.",
                                isPresented: $isShowingDeleteWorkoutAlert,
                                titleVisibility: .visible) {
                Button("Delete Workout", role: .destructive) {
                    workoutDetail.deleteWorkout()
                    dismiss()
                }
            }
                                .sheet(isPresented: $isShowingNewTemplate) {
                                    TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor(templateWorkout: Database.shared.newTemplateWorkout(from: workoutDetail.workout)))
                                }
                                .sheet(isPresented: $isShowingTemplateDetail) {
                                    NavigationView {
                                        WorkoutTemplateDetailView(workoutTemplateDetail: WorkoutTemplateDetail(workoutTemplateID: workoutDetail.workout.template?.objectID ?? NSManagedObjectID()))
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button("Dismiss") { isShowingTemplateDetail = false }
                                                }
                                            }
                                    }
                                }
    }
        
    //MARK: - Supporting Views
    
    private var TemplateView: some View {
        Section(content: {
            Button(action: {
                if workoutDetail.workout.template == nil {
                    isShowingNewTemplate = true
                } else {
                    isShowingTemplateDetail = true
                }
            }) {
                HStack {
                    if workoutDetail.workout.template == nil {
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                            .font(.body.weight(.medium))
                    } else {
                        Text("Template")
                            .foregroundColor(.secondaryLabel)
                        Spacer()
                    }
                    Text(workoutDetail.workout.template?.name ?? "New Template from Workout")
                        .fontWeight(.medium)
                        .foregroundColor(workoutDetail.workout.template == nil ? .accentColor : .label)
                    if workoutDetail.workout.template != nil {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondaryLabel)
                            .font(.body.weight(.medium))
                    } else {
                        Spacer()
                    }
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(10)
            }
        }, footer: {
            Text("Make your workout reusable and track your progress with it over time.")
                .font(.footnote)
                .foregroundColor(.secondaryLabel)
                .padding(.horizontal)
        }).listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private func Header(for setGroup: WorkoutSetGroup) -> some View {
        HStack {
            if let exercise = setGroup.exercise {
                NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(context: Database.shared.container.viewContext, exerciseID: exercise.objectID))) {
                    HStack {
                        Text("\((workoutDetail.workout.index(of: setGroup) ?? 0) + 1).")
                            .sectionHeaderStyle()
                        Text("\(exercise.name ?? "No Name")")
                            .foregroundColor(.label)
                            .font(.title2.weight(.semibold))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.separator)
                            .font(.caption.weight(.semibold))
                    }
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var Footer: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(workoutDetail.workoutDateString), \(workoutDetail.workoutTimeString)")
                Text("\(workoutDetail.workout.numberOfSetGroups) exercise\(workoutDetail.workout.numberOfSetGroups == 1 ? "" : "s"), \(workoutDetail.workout.numberOfSets) set\(workoutDetail.workout.numberOfSets == 1 ? "" : "s")")
            }.foregroundColor(.secondaryLabel)
                .font(.subheadline)
            Spacer()
        }.listRowSeparator(.hidden)
            .padding(.vertical, 50)
    }
    
    struct WorkoutSetCell: View {
        
        @ObservedObject var workoutSet: WorkoutSet
        
        var body: some View {
            HStack {
                if workoutSet.repetitions > 0 {
                    UnitView(value: String(workoutSet.repetitions), unit: "RPS")
                }
                if workoutSet.weight > 0 {
                    if workoutSet.repetitions > 0 {
                        dividerCircle
                            .padding(.horizontal, 8)
                    }
                    UnitView(value: String(convertWeightForDisplaying(workoutSet.weight)), unit: WeightUnit.used.rawValue.uppercased())
                } else {
                    UnitView(value: "", unit: "") //needed in order for cell not to collapse if reps and weight = 0
                }
            }.padding(.vertical, 5)
        }
                
        var dividerCircle: some View {
            Circle()
                .foregroundColor(.separator)
                .frame(width: 4, height: 4)
        }
        
    }
    
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(canNavigateToTemplate: .constant(true), workoutDetail: WorkoutDetail(context: Database.shared.container.viewContext, workoutID: NSManagedObjectID()))
    }
}
