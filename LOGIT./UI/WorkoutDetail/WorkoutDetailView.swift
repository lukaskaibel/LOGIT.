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
                    Text("\(setGroup.numberOfSets) \(NSLocalizedString("set\(setGroup.numberOfSets == 1 ? "" : "s")", comment: ""))")
                        .foregroundColor(.secondaryLabel)
                        .font(.subheadline)
                        .listRowSeparator(.hidden, edges: .bottom)
                }).padding(.leading)
            }.listRowInsets(EdgeInsets())
            Footer
        }.listStyle(.plain)
            .navigationTitle(workoutDetail.workout.name ?? "")
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
            .confirmationDialog(NSLocalizedString("deleteWorkoutDescription", comment: ""),
                                isPresented: $isShowingDeleteWorkoutAlert,
                                titleVisibility: .visible) {
                Button(NSLocalizedString("deleteWorkout", comment: ""), role: .destructive) {
                    workoutDetail.deleteWorkout()
                    dismiss()
                }
            }
                                .sheet(isPresented: $isShowingNewTemplate) {
                                    TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor(templateWorkout: workoutDetail.workout.template,
                                                                                                           from: workoutDetail.workout))
                                }
                                .sheet(isPresented: $isShowingTemplateDetail) {
                                    NavigationView {
                                        WorkoutTemplateDetailView(workoutTemplateDetail: WorkoutTemplateDetail(workoutTemplateID: workoutDetail.workout.template?.objectID ?? NSManagedObjectID()))
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button(NSLocalizedString("navBack", comment: "")) { isShowingTemplateDetail = false }
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
                        Text(NSLocalizedString("template", comment: ""))
                            .foregroundColor(.secondaryLabel)
                        Spacer()
                    }
                    Text(workoutDetail.workout.template?.name ?? NSLocalizedString("newTemplateFromWorkout", comment: ""))
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(.accentColor)
                    if workoutDetail.workout.template != nil {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.accentColor)
                            .font(.body.weight(.medium))
                    } else {
                        Spacer()
                    }
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(10)
            }
        }, footer: {
            Text(NSLocalizedString("templateExplanation", comment: ""))
                .font(.footnote)
                .foregroundColor(.secondaryLabel)
                .padding(.horizontal)
        }).listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private func Header(for setGroup: WorkoutSetGroup) -> some View {
        HStack {
            if let exercise = setGroup.exercise {
                NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: exercise.objectID))) {
                    HStack {
                        Text("\((workoutDetail.workout.index(of: setGroup) ?? 0) + 1).")
                            .sectionHeaderStyle()
                        Text("\(exercise.name ?? "")")
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
                Text("\(workoutDetail.workout.numberOfSetGroups) \(NSLocalizedString("exercise\(workoutDetail.workout.numberOfSetGroups == 1 ? "" : "s")", comment: "")) , \(workoutDetail.workout.numberOfSets) \(NSLocalizedString("set\(workoutDetail.workout.numberOfSets == 1 ? "" : "s")", comment: ""))")
            }.foregroundColor(.secondaryLabel)
                .font(.subheadline)
            Spacer()
        }.listRowSeparator(.hidden)
            .padding(.vertical, 50)
    }
    
    
    
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(canNavigateToTemplate: .constant(true), workoutDetail: WorkoutDetail(workoutID: NSManagedObjectID()))
    }
}
