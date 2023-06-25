//
//  WorkoutDetailView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    
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
        List {
            Section {
                workoutHeader
            }.listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            Section {
                workoutInfo
                setsPerMuscleGroup
            } header: {
                Text(NSLocalizedString("overview", comment: ""))
                    .sectionHeaderStyle()
            }
            .listRowInsets(EdgeInsets())
            ForEach(workout.setGroups) { setGroup in
                SetGroupDetailView(setGroup: setGroup,
                                   supplementaryText: "\(workout.setGroups.firstIndex(of: setGroup)! + 1) / \(workout.setGroups.count)  ·  \(setGroup.sets.count) \(NSLocalizedString("set" + (setGroup.sets.count == 1 ? "" : "s"), comment: ""))")
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            if canNavigateToTemplate {
                Section {
                    templateButton
                        .buttonStyle(PlainButtonStyle())
                } header: {
                    Text(NSLocalizedString("template", comment: ""))
                        .sectionHeaderStyle()
                } footer: {
                    Text(NSLocalizedString("templateExplanation", comment: ""))
                        .font(.footnote)
                        .foregroundColor(.secondaryLabel)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                }.listRowInsets(EdgeInsets())
            }
            Spacer(minLength: 50)
                .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .offset(x: 0, y: -30)
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle(workout.date?.description(.medium) ?? "")
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
            case .newTemplateFromWorkout: TemplateEditorView(template: database.newTemplate(from: workout),
                                                             isEditingExistingTemplate: false)
            case .templateDetail:
                NavigationStack {
                    TemplateDetailView(template: workout.template!)
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
        Text(workout.name ?? "")
            .font(.largeTitle.weight(.bold))
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var workoutInfo: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("starttime", comment: ""))
                    Text("\(workout.date?.timeString ?? "")")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.accentColor.gradient)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("duration", comment: ""))
                    Text("\(workoutDurationString)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.accentColor.gradient)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("exercises", comment: ""))
                    Text("\(workout.numberOfSetGroups)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.accentColor.gradient)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("sets", comment: ""))
                    Text("\(workout.numberOfSets)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.accentColor.gradient)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(CELL_PADDING)
    }
    
    private var setsPerMuscleGroup: some View {
        VStack {
            Text(NSLocalizedString("muscleGroups", comment: ""))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(CELL_PADDING)
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
            .padding()
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
        WorkoutDetailView(workout: Database.preview.testWorkout, canNavigateToTemplate: false)
            .environmentObject(Database.preview)
    }
}
