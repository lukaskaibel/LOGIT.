//
//  AllWorkoutsView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.12.21.
//

import SwiftUI

struct AllWorkoutsView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database
    
    // MARK: - State
    
    @State private var sortingKey: Database.WorkoutSortingKey = .date
    @State private var searchedText: String = ""
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(groupedWorkouts.indices, id:\.self) { index in
                Section(content: {
                    ForEach(groupedWorkouts.value(at: index) ?? [], id:\.objectID) { workout in
                        ZStack {
                            WorkoutCell(workout: workout)
                            NavigationLink(destination: WorkoutDetailView(workout: workout,
                                                                          canNavigateToTemplate: true)) {
                                EmptyView()
                            }.opacity(0).buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }.onDelete { indexSet in
                        for i in indexSet {
                            guard let workout = groupedWorkouts.value(at: index)?.value(at: i) else { return }
                            database.delete(workout, saveContext: true)
                        }
                    }
                }, header: {
                    Text(header(for: index))
                        .sectionHeaderStyle()
                })
            }
            Spacer(minLength: 50)
                .listRowSeparator(.hidden)
        }.listStyle(.plain)
            .searchable(text: $searchedText,
                        prompt: NSLocalizedString("searchWorkouts", comment: ""))
            .navigationTitle(NSLocalizedString("workouts", comment: ""))
            .toolbar  {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            Button(action: { sortingKey = .name }) {
                                Label(NSLocalizedString("name", comment: ""), systemImage: "textformat")
                            }
                            Button(action: { sortingKey = .date }) {
                                Label(NSLocalizedString("date", comment: ""), systemImage: "calendar")
                            }
                        }
                    } label: {
                        Label(NSLocalizedString(sortingKey == .name ? "name" : "date", comment: ""), systemImage: "arrow.up.arrow.down")
                    }
                }
            }
    }
    
    // MARK: - Supporting Methods
    
    private var groupedWorkouts: [[Workout]] {
        database.getGroupedWorkouts(withNameIncluding: searchedText, groupedBy: sortingKey)
    }
    
    private func header(for index: Int) -> String {
        switch sortingKey {
        case .date:
            guard let date = groupedWorkouts.value(at: index)?.first?.date else { return "" }
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        case .name:
            return String(groupedWorkouts.value(at: index)?.first?.name?.first ?? " ").capitalized
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
