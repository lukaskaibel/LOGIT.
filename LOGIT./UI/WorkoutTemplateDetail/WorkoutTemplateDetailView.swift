//
//  WorkoutTemplateDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 08.04.22.
//

import SwiftUI


struct WorkoutTemplateDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var workoutTemplateDetail: WorkoutTemplateDetail
    
    @State private var showingTemplateInfoAlert = false
    @State private var showingDeletionAlert = false
    @State private var showingTemplateEditor = false
    
    var body: some View {
        List {
            Section {
                templateHeader
            }.listRowSeparator(.hidden)
            Section {
                ForEach(workoutTemplateDetail.workoutTemplate.setGroups) { templateSetGroup in
                    TemplateSetGroupDetailView(templateSetGroup: templateSetGroup,
                                               indexInWorkout: workoutTemplateDetail.workoutTemplate.index(of: templateSetGroup) ?? 0)
                }
            } header: {
                Text("Summary")
                    .sectionHeaderStyle()
            }.listRowSeparator(.hidden)
            /*
            Section {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(NSLocalizedString("lastUsed", comment: ""))
                                .foregroundColor(.secondaryLabel)
                            HStack(alignment: .lastTextBaseline) {
                                Text(workoutTemplateDetail.lastUsedDateString)
                                    .font(.title.weight(.medium))
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    BarGraph(xValues: workoutTemplateDetail.graphXValues,
                             yValues: workoutTemplateDetail.graphYValues,
                             barColors: [Color](repeating: .accentColor, count: workoutTemplateDetail.graphYValues.count))
                        .frame(height: 150)
                    Picker("Calendar Component", selection: $workoutTemplateDetail.selectedCalendarComponent) {
                        Text(NSLocalizedString("weekly", comment: "")).tag(Calendar.Component.weekOfYear)
                        Text(NSLocalizedString("monthly", comment: "")).tag(Calendar.Component.month)
                        Text(NSLocalizedString("yearly", comment: "")).tag(Calendar.Component.year)
                    }.pickerStyle(.segmented)
                        .padding(.top)
                }.tileStyle()
                    .listRowSeparator(.hidden)
            }
            */
            Section(content: {
                ForEach(workoutTemplateDetail.workoutTemplate.workouts, id:\.objectID) { workout in
                    ZStack {
                        WorkoutCell(workout: workout)
                        NavigationLink(destination: WorkoutDetailView(canNavigateToTemplate: .constant(false
                                                                                                      ),
                                                                      workoutDetail: WorkoutDetail(workoutID: workout.objectID))) {
                            EmptyView()
                        }.opacity(0)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())

                }
            }, header: {
                Text("\(NSLocalizedString("performed", comment: "")) \(workoutTemplateDetail.workouts.count) \(NSLocalizedString("time\(workoutTemplateDetail.workouts.count == 1 ? "" : "s")", comment: ""))")
                    .sectionHeaderStyle()
            })
        }.listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString("lastUsed", comment: "") + " " + (workoutTemplateDetail.workoutTemplate.date?.description(.short) ?? ""))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Button(action: { showingTemplateEditor = true }, label: { Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil") })
                        Button(role: .destructive, action: {
                            showingDeletionAlert = true
                        }, label: { Label(NSLocalizedString("delete", comment: ""), systemImage: "trash") } )
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }

                }
            }
            .alert(NSLocalizedString("workoutTemplates", comment: ""),
                   isPresented: $showingTemplateInfoAlert,
                   actions: {  },
                   message: { Text(NSLocalizedString("templateExplanation", comment: "")) })
            .confirmationDialog(NSLocalizedString("deleteTemplateMsg", comment: ""), isPresented: $showingDeletionAlert) {
                Button(NSLocalizedString("deleteTemplate", comment: ""), role: .destructive) {
                    workoutTemplateDetail.deleteWorkoutTemplate()
                    dismiss()
                }
            }
            .sheet(isPresented: $showingTemplateEditor) {
                TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor(templateWorkout: workoutTemplateDetail.workoutTemplate))
            }
    }
    
    //MARK: - Supporting Views
    
    private var templateHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(workoutTemplateDetail.workoutTemplate.name ?? "")
                .font(.largeTitle.weight(.bold))
                .lineLimit(2)
            HStack {
                Image(systemName: "list.bullet.rectangle.portrait")
                Text(NSLocalizedString("template", comment: ""))
            }.font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(.secondaryLabel)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

