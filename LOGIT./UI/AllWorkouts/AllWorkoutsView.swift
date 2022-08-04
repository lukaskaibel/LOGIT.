//
//  AllWorkoutsView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.12.21.
//

import SwiftUI

struct AllWorkoutsView: View {
    
    @StateObject var allWorkouts = AllWorkouts()
    
    var body: some View {
        List {
            ForEach(allWorkouts.sectionedWorkouts.indices, id:\.self) { index in
                Section(content: {
                    ForEach(allWorkouts.sectionedWorkouts[index], id:\.objectID) { workout in
                        ZStack {
                            WorkoutCell(workout: workout)
                            NavigationLink(destination: WorkoutDetailView(canNavigateToTemplate: .constant(true),
                                                                          workoutDetail: WorkoutDetail(workoutID: workout.objectID))) {
                                EmptyView()
                            }.opacity(0).buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }.onDelete { indexSet in
                        for i in indexSet {
                            allWorkouts.delete(workout: allWorkouts.sectionedWorkouts[index][i])
                        }
                    }
                }, header: {
                    Text(allWorkouts.header(for: index))
                        .sectionHeaderStyle()
                })
            }
            Spacer(minLength: 50)
                .listRowSeparator(.hidden)
        }.listStyle(.plain)
            .searchable(text: $allWorkouts.searchedText,
                        prompt: NSLocalizedString("searchWorkouts", comment: ""))
            .navigationTitle(NSLocalizedString("workouts", comment: ""))
            .toolbar  {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(NSLocalizedString("sortBy", comment: "")) {
                        Section {
                            Button(action: {
                                allWorkouts.sortingKey = .name
                            }) {
                                Label(NSLocalizedString("name", comment: ""), systemImage: "textformat")
                            }
                            Button(action: {
                                allWorkouts.sortingKey = .date
                            }) {
                                Label(NSLocalizedString("date", comment: ""), systemImage: "calendar")
                            }
                        }
                    }
                }
            }
    }
    
    
    
}

struct AllWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllWorkoutsView()
        }
    }
}
