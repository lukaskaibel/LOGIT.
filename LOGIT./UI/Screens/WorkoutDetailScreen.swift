//
//  WorkoutDetailScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 20.12.21.
//

import CoreData
import SwiftUI

struct WorkoutDetailScreen: View {

    enum SheetType: Int, Identifiable {
        case newTemplateFromWorkout, templateDetail, workoutEditor
        var id: Int { self.rawValue }
    }

    // MARK: - Environment

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database

    // MARK: - State

    @State private var isShowingDeleteWorkoutAlert: Bool = false
    @State private var sheetType: SheetType? = nil

    // MARK: - Variables

    let workout: Workout
    let canNavigateToTemplate: Bool

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: SECTION_SPACING) {
                workoutHeader

                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("overview", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: CELL_SPACING) {
                        workoutInfo
                            .padding(CELL_PADDING)
                            .tileStyle()
                        setsPerMuscleGroup
                            .padding(CELL_PADDING)
                            .tileStyle()
                            .isBlockedWithoutPro()
                    }
                }

                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("exercises", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    WorkoutSetGroupList(
                        workout: workout,
                        focusedIntegerFieldIndex: .constant(nil),
                        sheetType: .constant(nil),
                        canReorder: false
                    )
                    .canEdit(false)
                }

                if canNavigateToTemplate {
                    VStack(spacing: SECTION_HEADER_SPACING) {
                        Text(NSLocalizedString("template", comment: ""))
                            .sectionHeaderStyle2()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        templateButton
                        Text(NSLocalizedString("templateExplanation", comment: ""))
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                    }
                    .buttonStyle(BigButtonStyle())
                }
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(
                        action: { 
                            sheetType = .workoutEditor
                        },
                        label: {
                            Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                        }
                    )
                    Button(
                        role: .destructive,
                        action: {
                            isShowingDeleteWorkoutAlert = true
                        }
                    ) {
                        Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            NSLocalizedString("deleteWorkoutDescription", comment: ""),
            isPresented: $isShowingDeleteWorkoutAlert,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("deleteWorkout", comment: ""), role: .destructive) {
                database.delete(workout, saveContext: true)
                dismiss()
            }
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case .newTemplateFromWorkout:
                TemplateEditorScreen(
                    template: database.newTemplate(from: workout),
                    isEditingExistingTemplate: false
                )
            case .templateDetail:
                NavigationStack {
                    TemplateDetailScreen(template: workout.template!)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("navBack", comment: "")) {
                                    sheetType = nil
                                }
                            }
                        }
                }
            case .workoutEditor:
                WorkoutEditorScreen(workout: workout, isAddingNewWorkout: false)
            }
        }
    }

    // MARK: - Supporting Views

    private var workoutHeader: some View {
        VStack(alignment: .leading) {
            Text(workout.date?.description(.long) ?? "")
                .screenHeaderTertiaryStyle()
            Text(workout.name ?? "")
                .screenHeaderStyle()
                .lineLimit(2)
            HStack {
                ForEach(workout.muscleGroups) { muscleGroup in
                    Text(muscleGroup.description)
                        .screenHeaderSecondaryStyle()
                        .foregroundStyle(muscleGroup.color.gradient)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var workoutInfo: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("starttime", comment: ""))
                        .foregroundColor(.secondary)
                    Text("\(workout.date?.timeString ?? "")")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("duration", comment: ""))
                        .foregroundColor(.secondary)
                    Text("\(workoutDurationString)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("exercises", comment: ""))
                        .foregroundColor(.secondary)
                    Text("\(workout.numberOfSetGroups)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("sets", comment: ""))
                        .foregroundColor(.secondary)
                    Text("\(workout.numberOfSets)")
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
                items: workout.muscleGroupOccurances.map {
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

    private var templateButton: some View {
        Button {
            sheetType = workout.template != nil ? .templateDetail : .newTemplateFromWorkout
        } label: {
            HStack {
                if workout.template == nil {
                    Image(systemName: "plus")
                        .font(.body.weight(.medium))
                }
                Text(
                    workout.template?.name
                        ?? NSLocalizedString("newTemplateFromWorkout", comment: "")
                )
                .fontWeight(.medium)
                .lineLimit(1)
                if workout.template != nil {
                    Spacer()
                    NavigationChevron()
                } else {
                    Spacer()
                }
            }
            .contentShape(Rectangle())
        }
    }

    // MARK: - Computed Properties

    private var workoutDurationString: String {
        guard let start = workout.date, let end = workout.endDate else { return "0:00" }
        let hours = Calendar.current.dateComponents([.hour], from: start, to: end).hour ?? 0
        let minutes =
            (Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0) % 60
        return "\(hours):\(minutes < 10 ? "0" : "")\(minutes)"
    }

}

private struct PreviewWrapperView: View {
    @EnvironmentObject private var database: Database
    
    var body: some View {
        NavigationStack {
            WorkoutDetailScreen(
                workout: database.getWorkouts().first!,
                canNavigateToTemplate: false
            )
        }
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapperView()
            .previewEnvironmentObjects()
    }
}
