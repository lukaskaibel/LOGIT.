//
//  WorkoutRecorderStartScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct WorkoutRecorderStartScreen: View {
    
    @EnvironmentObject var workoutRecorder: WorkoutRecorder
    @Environment(\.dismiss) var dismiss
    @FetchRequest(entity: TemplateWorkout.entity(),
                  sortDescriptors: [NSSortDescriptor(key: "creationDate", ascending: false)])
    var workoutTemplates: FetchedResults<TemplateWorkout>
    
    @Binding var showingStartScreen: Bool
    
    var body: some View {
        List {
            Text("Choose a template or start an empty workout")
                .foregroundColor(.secondaryLabel)
                .font(.subheadline)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
            Section {
                Button(action: { showingStartScreen = false }) {
                    HStack(spacing: 15) {
                        Image(systemName: "square.dashed")
                            .resizable()
                            .font(.body.weight(.thin))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "plus")
                            }
                        Text("Start Empty Workout")
                            .font(.body.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.font(.body.weight(.medium))
                        .foregroundColor(.accentColor)
                        .frame(height: 60)
                }
            }
            Section(content: {
                ForEach(workoutTemplates, id:\.objectID) { template in
                    Button(action: {
                        workoutRecorder.template = template
                        showingStartScreen = false
                    }) {
                        HStack {
                            WorkoutTemplateCell(workoutTemplate: template)
                                .foregroundColor(.label)
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.medium))
                        }
                    }
                }
            }, header: {
                Text("My Templates")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.label)
                    .padding(.vertical, 5)
            }, footer: {
                Text("Templates can be added in your profile or from an existing workout.")
            }).textCase(.none)
        }.navigationTitle("Start Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {
                        workoutRecorder.deleteWorkout()
                        dismiss()
                    }
                }
            }
    }
}

struct WorkoutRecorderStartScreen_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecorderStartScreen(showingStartScreen: .constant(true))
    }
}
