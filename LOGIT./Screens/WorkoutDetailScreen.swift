//
//  WorkoutDetailScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

struct WorkoutDetailScreen: View {
    
    enum SheetType: Int, Identifiable {
        case newTemplateFromWorkout, templateDetail
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
                    workoutInfo
                        .padding(CELL_PADDING)
                        .tileStyle()
                }
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("muscleGroups", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    setsPerMuscleGroup
                        .padding(CELL_PADDING)
                        .tileStyle()
                }
                VStack(spacing: SECTION_HEADER_SPACING) {
                    Text(NSLocalizedString("exercises", comment: ""))
                        .sectionHeaderStyle2()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    WorkoutSetGroupList(
                        workout: workout,
                        focusedIntegerFieldIndex: .constant(nil),
                        sheetType: .constant(nil),
                        isReordering: .constant(false)
                    )
                    .canEdit(false)
                }
                if canNavigateToTemplate {
                    VStack(spacing: SECTION_HEADER_SPACING) {
                        Text(NSLocalizedString("template", comment: ""))
                            .sectionHeaderStyle2()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        templateButton
                            .bigButton()
                        Text(NSLocalizedString("templateExplanation", comment: ""))
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, SCROLLVIEW_BOTTOM_PADDING)
            .padding(.horizontal)
        }
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
                database.delete(workout, saveContext: true)
                dismiss()
            }
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case .newTemplateFromWorkout: TemplateEditorScreen(template: database.newTemplate(from: workout),
                                                             isEditingExistingTemplate: false)
            case .templateDetail:
                NavigationStack {
                    TemplateDetailScreen(template: workout.template!)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(NSLocalizedString("navBack", comment: "")) { sheetType = nil }
                            }
                        }
                }
            }
        }
    }
        
    // MARK: - Supporting Views
    
    private var workoutHeader: some View {
        VStack(alignment: .leading) {
            Text(workout.date?.description(.long) ?? "")
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(workout.name ?? "")
                .font(.largeTitle.weight(.bold))
                .lineLimit(2)
            HStack {
                ForEach(workout.muscleGroups) { muscleGroup in
                    Text(muscleGroup.description)
                        .font(.system(.title2, design: .rounded, weight: .semibold))
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
                    Text("\(workout.date?.timeString ?? "")")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .muscleGroupGradientStyle(for: workout.muscleGroups)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("duration", comment: ""))
                    Text("\(workoutDurationString)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .muscleGroupGradientStyle(for: workout.muscleGroups)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("exercises", comment: ""))
                    Text("\(workout.numberOfSetGroups)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .muscleGroupGradientStyle(for: workout.muscleGroups)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("sets", comment: ""))
                    Text("\(workout.numberOfSets)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .muscleGroupGradientStyle(for: workout.muscleGroups)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var setsPerMuscleGroup: some View {
        PieGraph(
            items: workout.muscleGroupOccurances.map {
                PieGraph.Item(title: $0.0.rawValue.capitalized,
                              amount: $0.1,
                              color: $0.0.color,
                              isSelected: false
                )
            }
        )
    }
    
    private var templateButton: some View {
        Button {
                sheetType = workout.template != nil ? .templateDetail : .newTemplateFromWorkout
        } label: {
            HStack {
                if workout.template == nil {
                    Image(systemName: "plus")
                        .foregroundColor(.accentColor)
                        .font(.body.weight(.medium))
                }
                Text(workout.template?.name ?? NSLocalizedString("newTemplateFromWorkout", comment: ""))
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.accentColor)
                if workout.template != nil {
                    Spacer()
                    NavigationChevron()
                        .foregroundColor(.accentColor)
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
        let minutes = (Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0) % 60
        return "\(hours):\(minutes < 10 ? "0" : "")\(minutes)"
    }
    
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutDetailScreen(
                workout: Database.preview.getWorkouts().first!,
                canNavigateToTemplate: false
            )
        }
        .environmentObject(Database.preview)
    }
}
