//
//  WorkoutTemplateListView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    
    // MARK: - State Objects
    
    @StateObject private var workoutTemplateList = WorkoutTemplateList()
    
    // MARK: - State
    
    @State private var showingTemplateCreation = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(workoutTemplateList.templateWorkouts, id:\.objectID) { templateWorkout in
                ZStack {
                    WorkoutTemplateCell(workoutTemplate: templateWorkout)
                    NavigationLink(destination: WorkoutTemplateDetailView(workoutTemplateDetail: WorkoutTemplateDetail(workoutTemplateID: templateWorkout.objectID))) {
                        EmptyView()
                    }.opacity(0)
                }
            }.onDelete { indexSet in
                workoutTemplateList.templateWorkouts
                    .elements(for: indexSet)
                    .forEach { workoutTemplateList.delete($0) }
            }
            .listRowSeparator(.hidden)
        }.listStyle(.plain)
            .searchable(text: $workoutTemplateList.searchedText)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(NSLocalizedString("templates", comment: ""))
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
