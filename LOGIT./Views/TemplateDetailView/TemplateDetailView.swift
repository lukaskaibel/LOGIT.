//
//  WorkoutTemplateDetailView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 08.04.22.
//

import SwiftUI


struct TemplateDetailView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var showingTemplateInfoAlert = false
    @State private var showingDeletionAlert = false
    @State private var showingTemplateEditor = false
    
    // MARK: - Variables
    
    let workoutTemplate: TemplateWorkout
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                templateHeader
            }.listRowSeparator(.hidden)
            Section {
                ForEach(workoutTemplate.setGroups) { templateSetGroup in
                    TemplateSetGroupDetailView(templateSetGroup: templateSetGroup,
                                               indexInWorkout: workoutTemplate.index(of: templateSetGroup) ?? 0)
                }
            } header: {
                Text("Summary")
                    .sectionHeaderStyle()
            }.listRowSeparator(.hidden)
            Section(content: {
                workoutList
            }, header: {
                Text("\(NSLocalizedString("performed", comment: "")) \(workoutTemplate.workouts.count) \(NSLocalizedString("time\(workoutTemplate.workouts.count == 1 ? "" : "s")", comment: ""))")
                    .sectionHeaderStyle()
            })
        }.listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString("lastUsed", comment: "") + " " + (workoutTemplate.date?.description(.short) ?? ""))
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
                    database.delete(workoutTemplate, saveContext: true)
                    dismiss()
                }
            }
            .sheet(isPresented: $showingTemplateEditor) {
                TemplateEditorView(templateWorkoutEditor: TemplateEditor(templateWorkout: workoutTemplate))
            }
    }
    
    // MARK: - Supporting Views
    
    private var templateHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(workoutTemplate.name ?? "")
                .font(.largeTitle.weight(.bold))
                .lineLimit(2)
            HStack {
                Image(systemName: "list.bullet.rectangle.portrait")
                Text(NSLocalizedString("template", comment: ""))
            }.font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(.secondaryLabel)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var workoutList: some View {
        ForEach(workoutTemplate.workouts, id:\.objectID) { workout in
            ZStack {
                WorkoutCell(workout: workout)
                NavigationLink(destination: WorkoutDetailView(workout: workout,
                                                              canNavigateToTemplate: false)) {
                    EmptyView()
                }.opacity(0)
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())

        }
    }
    
    // MARK: - Supporting Methods
    
    private var lastUsedDateString: String {
        workoutTemplate.workouts.first?.date?.description(.medium) ?? NSLocalizedString("never", comment: "")
    }
    
}

