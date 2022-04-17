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
            Section(content: {
                ForEach(workoutTemplateDetail.workoutTemplate.workouts?.array as? [Workout] ?? .emptyList, id:\.objectID) { workout in
                    WorkoutCellView(workout: workout, canNavigateToTemplate: .constant(false))
                }
            }, header: {
                Text("\(NSLocalizedString("performed", comment: "")) \(workoutTemplateDetail.workouts.count) \(NSLocalizedString("time\(workoutTemplateDetail.workouts.count == 1 ? "" : "s")", comment: ""))")
                    .sectionHeaderStyle()
            })
        }.listStyle(.plain)
            .navigationTitle(workoutTemplateDetail.workoutTemplate.name ?? "")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingTemplateInfoAlert = true
                    }) {
                        Text(NSLocalizedString("template", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondaryLabel)
                            .padding(5)
                            .background(Color.fill)
                            .clipShape(Capsule())
                    }
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
}

