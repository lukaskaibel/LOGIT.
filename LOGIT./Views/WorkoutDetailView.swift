//
//  WorkoutDetailView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 20.12.21.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var isShowingDeleteWorkoutAlert: Bool = false
    @State private var isShowingNewTemplate: Bool = false
    @State private var isShowingTemplateDetail: Bool = false
    
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
            }.listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            Section {
                setsPerMuscleGroup
            } header: {
                Text(NSLocalizedString("muscleGroups", comment: ""))
                    .sectionHeaderStyle()
            }.listRowInsets(EdgeInsets())
            Section {
                ForEach(workout.setGroups) { setGroup in
                    SetGroupDetailView(setGroup: setGroup,
                                       indexInWorkout: workout.index(of: setGroup) ?? 1)
                }.padding(CELL_PADDING)
                    .listRowSeparator(.hidden)
            } header: {
                Text(NSLocalizedString("summary", comment: ""))
                    .sectionHeaderStyle()
            }.listRowInsets(EdgeInsets())
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
        }.listStyle(.insetGrouped)
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
                                .sheet(isPresented: $isShowingNewTemplate) {
                                    TemplateEditorView(templateEditor: TemplateEditor(template: workout.template,
                                                                                                           from: workout))
                                }
                                .sheet(isPresented: $isShowingTemplateDetail) {
                                    NavigationView {
                                        TemplateDetailView(template: workout.template!)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button(NSLocalizedString("navBack", comment: "")) { isShowingTemplateDetail = false }
                                                }
                                            }
                                    }
                                }
    }
        
    // MARK: - Supporting Views
    
    private var workoutHeader: some View {
        Text(workout.name ?? "")
            .font(.largeTitle.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var workoutInfo: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("starttime", comment: ""))
                    Text("\(workout.date?.timeString ?? "")")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("duration", comment: ""))
                    Text("\(workoutDurationString)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("exercises", comment: ""))
                    Text("\(workout.numberOfSetGroups)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("sets", comment: ""))
                    Text("\(workout.numberOfSets)")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.accentColor)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var setsPerMuscleGroup: some View {
        PieGraph(items: workout.muscleGroupOccurances
            .map { PieGraph.Item(title: $0.0.rawValue.capitalized,
                                 amount: $0.1,
                                 color: $0.0.color) }
        ).tileStyle()
    }
    
    private var templateButton: some View {
            Button(action: {
                if workout.template == nil {
                    isShowingNewTemplate = true
                } else {
                    isShowingTemplateDetail = true
                }
            }) {
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
    }
    
    // MARK: - Supporting Methods
    
    private var workoutDurationString: String {
        guard let start = workout.date, let end = workout.endDate else { return "0:00" }
        let hours = Calendar.current.dateComponents([.hour], from: start, to: end).hour ?? 0
        let minutes = Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0
        return "\(hours):\(minutes < 10 ? "0" : "")\(minutes)"
    }
    
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(workout: Database.preview.testWorkout, canNavigateToTemplate: false)
            .environmentObject(Database.preview)
    }
}
