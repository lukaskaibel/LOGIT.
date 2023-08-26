//
//  TemplateDetailScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 08.04.22.
//

import SwiftUI

struct TemplateDetailScreen: View {

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
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("overview", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: CELL_SPACING) {
                        templateInfo
                            .padding(CELL_PADDING)
                            .tileStyle()
                        setsPerMuscleGroup
                            .padding(CELL_PADDING)
                            .tileStyle()
                    }
                }
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("exercises", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    exercisesList
                }
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(
                        "\(NSLocalizedString("performed", comment: "")) \(template.workouts.count) \(NSLocalizedString("time\(template.workouts.count == 1 ? "" : "s")", comment: ""))"
                    )
                    .sectionHeaderStyle2()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    workoutList
                }
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
            .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Workout.self) { selectedWorkout in
            WorkoutDetailScreen(workout: selectedWorkout, canNavigateToTemplate: false)
        }
        .navigationTitle(NSLocalizedString("template", comment: ""))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button(
                        action: { showingTemplateEditor = true },
                        label: {
                            Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                        }
                    )
                    Button(
                        role: .destructive,
                        action: {
                            showingDeletionAlert = true
                        },
                        label: {
                            Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                        }
                    )
                }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(
            NSLocalizedString("templates", comment: ""),
            isPresented: $showingTemplateInfoAlert,
            actions: {},
            message: { Text(NSLocalizedString("templateExplanation", comment: "")) }
        )
        .confirmationDialog(
            NSLocalizedString("deleteTemplateMsg", comment: ""),
            isPresented: $showingDeletionAlert
        ) {
            Button(NSLocalizedString("deleteTemplate", comment: ""), role: .destructive) {
                database.delete(template, saveContext: true)
                dismiss()
            }
        }
        .sheet(isPresented: $showingTemplateEditor) {
            TemplateEditorScreen(template: template, isEditingExistingTemplate: true)
        }
    }

    // MARK: - Supporting Views

    private var templateHeader: some View {
        VStack(alignment: .leading) {
            Text(
                template.lastUsed != nil
                    ? (NSLocalizedString("lastUsed", comment: "") + " "
                        + (template.lastUsed?.description(.long) ?? ""))
                    : NSLocalizedString("unused", comment: "")
            )
            .screenHeaderTertiaryStyle()
            Text(template.name ?? "")
                .screenHeaderStyle()
                .lineLimit(2)
            HStack {
                ForEach(template.muscleGroups) { muscleGroup in
                    Text(muscleGroup.description)
                        .screenHeaderSecondaryStyle()
                        .foregroundStyle(muscleGroup.color.gradient)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var templateInfo: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("exercises", comment: ""))
                        .foregroundColor(.secondary)
                    Text("\(template.numberOfSetGroups)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("sets", comment: ""))
                        .foregroundColor(.secondary)
                    Text("\(template.sets.count)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var setsPerMuscleGroup: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("muscleGroups", comment: ""))
                .tileHeaderStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
            PieGraph(
                items: template.muscleGroupOccurances.map {
                    PieGraph.Item(
                        title: $0.0.rawValue.capitalized,
                        amount: $0.1,
                        color: $0.0.color,
                        isSelected: false
                    )
                }
            )
        }
    }

    private var exercisesList: some View {
        VStack(spacing: CELL_SPACING) {
            ForEach(template.setGroups) { templateSetGroup in
                TemplateSetGroupCell(
                    setGroup: templateSetGroup,
                    focusedIntegerFieldIndex: .constant(nil),
                    sheetType: .constant(nil),
                    isReordering: .constant(false),
                    supplementaryText:
                        "\(template.setGroups.firstIndex(of: templateSetGroup)! + 1) / \(template.setGroups.count)  ·  \(templateSetGroup.setType.description)"
                )
                .padding(CELL_PADDING)
                .tileStyle()
                .canEdit(false)
            }
        }
    }

    private var workoutList: some View {
        ForEach(template.workouts, id: \.objectID) { workout in
            NavigationLink(value: workout) {
                WorkoutCell(workout: workout)
            }
            .padding(CELL_PADDING)
            .tileStyle()
            .buttonStyle(TileButtonStyle())
        }
    }

    // MARK: - Computed Properties

    private var lastUsedDateString: String {
        template.workouts.first?.date?.description(.medium)
            ?? NSLocalizedString("never", comment: "")
    }

}

struct TemplateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TemplateDetailScreen(template: Database.preview.testTemplate)
        }
        .environmentObject(Database.preview)
    }
}
