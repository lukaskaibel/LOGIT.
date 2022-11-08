//
//  TemplateDetailView.swift
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
    
    let template: Template
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                templateHeader
            }.listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            Section {
                ForEach(template.setGroups) { templateSetGroup in
                    TemplateSetGroupDetailView(templateSetGroup: templateSetGroup,
                                               indexInWorkout: template.index(of: templateSetGroup) ?? 0)
                }.padding(CELL_PADDING)
                    .listRowSeparator(.hidden)
            } header: {
                Text("Summary")
                    .sectionHeaderStyle()
            }.listRowInsets(EdgeInsets())
            Section(content: {
                workoutList
            }, header: {
                Text("\(NSLocalizedString("performed", comment: "")) \(template.workouts.count) \(NSLocalizedString("time\(template.workouts.count == 1 ? "" : "s")", comment: ""))")
                    .sectionHeaderStyle()
            }).listRowInsets(EdgeInsets())
        }.listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString("lastUsed", comment: "") + " " + (template.date?.description(.short) ?? ""))
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
            .alert(NSLocalizedString("templates", comment: ""),
                   isPresented: $showingTemplateInfoAlert,
                   actions: {  },
                   message: { Text(NSLocalizedString("templateExplanation", comment: "")) })
            .confirmationDialog(NSLocalizedString("deleteTemplateMsg", comment: ""), isPresented: $showingDeletionAlert) {
                Button(NSLocalizedString("deleteTemplate", comment: ""), role: .destructive) {
                    database.delete(template, saveContext: true)
                    dismiss()
                }
            }
            .sheet(isPresented: $showingTemplateEditor) {
                TemplateEditorView(template: template, isEditingExistingTemplate: true)
            }
    }
    
    // MARK: - Supporting Views
    
    private var templateHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(template.name ?? "")
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
        ForEach(template.workouts, id:\.objectID) { workout in
            ZStack {
                WorkoutCell(workout: workout)
                NavigationLink(destination: WorkoutDetailView(workout: workout,
                                                              canNavigateToTemplate: false)) {
                    EmptyView()
                }.opacity(0)
            }
        }.padding(CELL_PADDING)
    }
    
    // MARK: - Supporting Methods
    
    private var lastUsedDateString: String {
        template.workouts.first?.date?.description(.medium) ?? NSLocalizedString("never", comment: "")
    }
    
}

