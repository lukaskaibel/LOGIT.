//
//  WorkoutTemplateListView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    
    @StateObject private var workoutTemplateList = WorkoutTemplateList()
    
    @State private var showingTemplateCreation = false
    
    var body: some View {
        List {
            ForEach(workoutTemplateList.templateWorkouts, id:\.objectID) { templateWorkout in
                NavigationLink(destination: WorkoutTemplateDetailView(workoutTemplateDetail: WorkoutTemplateDetail(workoutTemplateID: templateWorkout.objectID))) {
                    WorkoutTemplateCell(workoutTemplate: templateWorkout)
                }
            }.onDelete { indexSet in
                workoutTemplateList.templateWorkouts
                    .elements(for: indexSet)
                    .forEach { workoutTemplateList.delete($0) }
            }
        }.listStyle(.plain)
            .navigationTitle("Workout Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingTemplateCreation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .popover(isPresented: $showingTemplateCreation) {
                TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor())
            }
    }
}

struct WorkoutTemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTemplateListView()
    }
}
