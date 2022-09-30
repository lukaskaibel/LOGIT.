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
    
    static let columnWidth: CGFloat = 70
    static let columnSpace: CGFloat = 20
    
    var body: some View {
        List {
            WorkoutHeader
            ForEach(workoutDetail.setGroups) { setGroup in
                Section {
                    VStack(spacing: 0) {
                        Divider()
                            .padding(.leading)
                        ForEach(setGroup.sets, id:\.objectID) { workoutSet in
                            VStack(alignment: .trailing, spacing: 0) {
                                EmptyView()
                                    .frame(height: 1)
                                HStack {
                                    Text("\(NSLocalizedString("set", comment: "")) \((setGroup.index(of: workoutSet) ?? 0) + 1)")
                                        .font(.body.monospacedDigit())
                                    WorkoutSetCell(workoutSet: workoutSet)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                }
                                Divider()
                            }.padding(.leading)
                        }
                    }.listRowSeparator(.hidden)
                } header: {
                    Header(for: setGroup)
                        .listRowInsets(EdgeInsets())
                }.padding(.leading)
            }.listRowInsets(EdgeInsets())
            if canNavigateToTemplate {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 1)
                    .listRowSeparator(.hidden)
                TemplateView
                    .buttonStyle(PlainButtonStyle())
            }
        }.listStyle(.plain)
            .navigationTitle(workoutDetail.workout.date?.description(.medium) ?? "")
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
    
    private var WorkoutHeader: some View {
        HStack {
            Image(systemName: "swift")
                .font(.title)
                .foregroundColor(.accentColor)
                .padding()
                .background(LinearGradient(colors: [.accentColor.opacity(0.03), .accentColor.opacity(0.3)],
                                           startPoint: .leading,
                                           endPoint: .trailing))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(workoutDetail.workout.name ?? "No Name")
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                Text("\(workoutDetail.workout.numberOfSetGroups) \(NSLocalizedString("exercise\(workoutDetail.workout.numberOfSetGroups == 1 ? "" : "s")", comment: "")) , \(workoutDetail.workout.numberOfSets) \(NSLocalizedString("set\(workoutDetail.workout.numberOfSets == 1 ? "" : "s")", comment: ""))")
                    .foregroundColor(.accentColor)
            }
            Spacer()
        }.listRowSeparator(.hidden)
    }
    
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
        VStack(spacing: 3) {
            HStack {
                if let exercise = setGroup.exercise {
                    Text("\((workoutDetail.workout.index(of: setGroup) ?? 0) + 1).")
                    NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: exercise.objectID))) {
                        HStack(spacing: 3) {
                            Text("\(exercise.name ?? "")")
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.separator)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
            }.font(.body.weight(.semibold))
                .foregroundColor(.label)
            if setGroup.setType == .superSet, let secondaryExercise = setGroup.secondaryExercise {
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption) 
                    NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(exerciseID: secondaryExercise.objectID))) {
                        HStack(spacing: 3) {
                            Text("\(secondaryExercise.name ?? "")")
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.separator)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }.padding(.leading, 30)
            }
            HStack(spacing: WorkoutDetailView.columnSpace) {
                Spacer()
                Text(NSLocalizedString("reps", comment: "").uppercased())
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
                    .frame(maxWidth: WorkoutDetailView.columnWidth)
                Text(WeightUnit.used.rawValue.uppercased())
                    .font(.footnote)
                    .foregroundColor(.secondaryLabel)
                    .frame(maxWidth: WorkoutDetailView.columnWidth)
            }.padding(.horizontal)
        }.font(.body.weight(.semibold))
            .foregroundColor(.label)
            .padding(.top)
            .padding(.bottom, 5)
    }
    
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(canNavigateToTemplate: .constant(false),
                          workoutDetail: WorkoutDetail(workoutID: (Database.preview.fetch(Workout.self).first! as! Workout).objectID))
    }
}
