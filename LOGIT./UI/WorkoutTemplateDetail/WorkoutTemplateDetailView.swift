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
                            Text("Last used")
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
                        Text("Weekly").tag(Calendar.Component.weekOfYear)
                        Text("Monthly").tag(Calendar.Component.month)
                        Text("Yearly").tag(Calendar.Component.year)
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
                Text("Performed \(workoutTemplateDetail.workouts.count) time\(workoutTemplateDetail.workouts.count == 1 ? "" : "s")")
                    .sectionHeaderStyle()
            })
        }.listStyle(.plain)
            .navigationTitle(workoutTemplateDetail.workoutTemplate.name ?? "")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingTemplateInfoAlert = true
                    }) {
                        Text("Template")
                            .font(.caption)
                            .foregroundColor(.secondaryLabel)
                            .padding(5)
                            .background(Color.fill)
                            .clipShape(Capsule())
                    }
                    Menu(content: {
                        Button(action: { showingTemplateEditor = true }, label: { Label("Edit", systemImage: "pencil") })
                        Button(role: .destructive, action: {
                            showingDeletionAlert = true
                        }, label: { Label("Delete", systemImage: "trash") } )
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }

                }
            }
            .alert("Workout Templates",
                   isPresented: $showingTemplateInfoAlert,
                   actions: {  },
                   message: { Text("Workout Templates make it possible to plan workouts before your training and track your progress for specific workouts over time.") })
            .confirmationDialog("Do you want to delete this Template? This cannot be undone.", isPresented: $showingDeletionAlert) {
                Button("Delete Template", role: .destructive) {
                    workoutTemplateDetail.deleteWorkoutTemplate()
                    dismiss()
                }
            }
            .sheet(isPresented: $showingTemplateEditor) {
                TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor(templateWorkout: workoutTemplateDetail.workoutTemplate))
            }
    }
}

