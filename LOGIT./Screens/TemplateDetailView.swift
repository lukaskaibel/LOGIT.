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
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                templateHeader
                    .padding(.horizontal)
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("exercises", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVStack(spacing: CELL_SPACING) {
                        ForEach(template.setGroups) { templateSetGroup in
                            TemplateSetGroupDetailView(
                                templateSetGroup: templateSetGroup,
                                supplementaryText: "\(template.setGroups.firstIndex(of: templateSetGroup)! + 1) / \(template.setGroups.count)  ·  \(templateSetGroup.sets.count) \(NSLocalizedString("set" + (templateSetGroup.sets.count == 1 ? "" : "s"), comment: ""))"
                            )
                            .padding(CELL_PADDING)
                            .tileStyle()
                        }
                    }
                }
                .padding(.horizontal)
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text("\(NSLocalizedString("performed", comment: "")) \(template.workouts.count) \(NSLocalizedString("time\(template.workouts.count == 1 ? "" : "s")", comment: ""))")
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    workoutList
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Workout.self) { selectedWorkout in
            WorkoutDetailView(workout:  selectedWorkout, canNavigateToTemplate: false)
        }
        .navigationTitle(template.lastUsed != nil ? (NSLocalizedString("lastUsed", comment: "") + " " + (template.lastUsed?.description(.short) ?? "")) : NSLocalizedString("unused", comment: ""))
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
            NavigationLink(value: workout) {
                WorkoutCell(workout: workout)
            }
            .padding(CELL_PADDING)
            .tileStyle()
        }
    }
    
    // MARK: - Computed Properties
    
    private var lastUsedDateString: String {
        template.workouts.first?.date?.description(.medium) ?? NSLocalizedString("never", comment: "")
    }
    
}


struct TemplateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TemplateDetailView(template: Database.preview.testTemplate)
        }
        .environmentObject(Database.preview)
    }
}
