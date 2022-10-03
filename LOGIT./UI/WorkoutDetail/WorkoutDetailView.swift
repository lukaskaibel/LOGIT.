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
            Section {
                workoutHeader
            }.padding(.bottom)
                .listRowSeparator(.hidden, edges: .top)
            Section {
                workoutInfo
            }
            Section {
                setsPerMuscleGroup
            } header: {
                Text("Sets per Muscle Group")
                    .sectionHeaderStyle()
            }.listRowSeparator(.hidden)
            Section {
                ForEach(workoutDetail.setGroups) { setGroup in
                    SetGroupDetailView(setGroup: setGroup,
                                       indexInWorkout: workoutDetail.workout.index(of: setGroup) ?? 1)
                }
            } header: {
                Text("Summary")
                    .sectionHeaderStyle()
            }.listRowSeparator(.hidden)
            if canNavigateToTemplate {
                Section {
                    templateView
                        .buttonStyle(PlainButtonStyle())
                } header: {
                    Text(NSLocalizedString("template", comment: ""))
                        .sectionHeaderStyle()
                }
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
    
    private var workoutHeader: some View {
        Text(workoutDetail.workout.name ?? "")
            .font(.largeTitle.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var workoutInfo: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("starttime", comment: ""))
                    Text("\(workoutDetail.workout.date?.timeString ?? "")")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("duration", comment: ""))
                    Text("\(workoutDetail.workoutDurationString)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("exercises", comment: ""))
                    Text("\(workoutDetail.workout.numberOfSetGroups)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("sets", comment: ""))
                    Text("\(workoutDetail.workout.numberOfSets)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var setsPerMuscleGroup: some View {
        PieGraph(items: workoutDetail.workout.muscleGroupOccurances
            .map { PieGraph.Item(title: $0.0.rawValue.capitalized,
                                 amount: $0.1,
                                 color: $0.0.color) }
        ).tileStyle()
    }
    
    private var templateView: some View {
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
                    }
                    Text(workoutDetail.workout.template?.name ?? NSLocalizedString("newTemplateFromWorkout", comment: ""))
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(.accentColor)
                    if workoutDetail.workout.template != nil {
                        Spacer()
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
    
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(canNavigateToTemplate: .constant(false),
                          workoutDetail: WorkoutDetail(workoutID: (Database.preview.fetch(Workout.self).first! as! Workout).objectID))
    }
}
