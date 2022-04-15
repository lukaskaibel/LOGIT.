//
//  AllWorkoutsView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.12.21.
//

import SwiftUI
import CoreData


struct AllWorkoutsView: View {
    
    @ObservedObject var allWorkouts: AllWorkouts
    
    init(context: NSManagedObjectContext) {
        self.allWorkouts = AllWorkouts(context: context)
    }
    
    var body: some View {
        List {
            ForEach(allWorkouts.sectionedWorkouts.indices, id:\.self) { index in
                Section(content: {
                    ForEach(allWorkouts.sectionedWorkouts[index], id:\.objectID) { workout in
                        WorkoutCellView(workout: workout, canNavigateToTemplate: .constant(true))
                    }.onDelete { indexSet in
                        for i in indexSet {
                            allWorkouts.delete(workout: allWorkouts.sectionedWorkouts[index][i])
                        }
                    }
                }, header: {
                    if let date = allWorkouts.sectionedWorkouts[index].first?.date {
                        Text(dateString(for: date))
                            .foregroundColor(.label)
                            .font(.title2.weight(.bold))
                            .padding(.bottom, 5)
                    }
                })
            }
            Spacer(minLength: 50)
                .listRowSeparator(.hidden, edges: .bottom)
        }.listStyle(.plain)
            .searchable(text: $allWorkouts.searchedText,
                        prompt: NSLocalizedString("searchWorkouts", comment: "Searching in workouts"))
            .navigationTitle(NSLocalizedString("workouts", comment: "Collection of exercises"))
            .toolbar  {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(NSLocalizedString("sortBy", comment: "Order of a list")) {
                        Section {
                            Button(action: {
                                if allWorkouts.sortingKey != .name {
                                    allWorkouts.ascending = true
                                }
                                allWorkouts.sortingKey = .name
                            }) {
                                Label(NSLocalizedString("name", comment: "What you call a person"), systemImage: "textformat")
                            }
                            Button(action: {
                                if allWorkouts.sortingKey != .date {
                                    allWorkouts.ascending = false
                                }
                                allWorkouts.sortingKey = .date
                            }) {
                                Label(NSLocalizedString("date", comment: ""), systemImage: "calendar")
                            }
                        }
                        Section {
                            Button(allWorkouts.sortingKey == .name ? NSLocalizedString("ascending", comment: "") : NSLocalizedString("oldestFirst", comment: "")) {
                                allWorkouts.ascending = true
                            }
                            Button(allWorkouts.sortingKey == .name ? NSLocalizedString("oldestFirst", comment: "") : NSLocalizedString("newestFirst", comment: "")) {
                                allWorkouts.ascending = false
                            }
                        }
                    }
                }
            }
    }
    
    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
}

struct AllWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllWorkoutsView(context: Database.preview.container.viewContext)
        }
    }
}
