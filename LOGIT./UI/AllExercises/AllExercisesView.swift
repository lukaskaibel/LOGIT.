//
//  AllExercisesView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 19.03.22.
//

import SwiftUI

struct AllExercisesView: View {
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var exercises: FetchedResults<Exercise>
        
    @State private var searchedText = ""
    @State private var showingAddExercise = false
    
    var body: some View {
        List {
            ForEach(groupedExercises) { group in
                Section(content: {
                    ForEach(group, id: \.objectID) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exerciseDetail: ExerciseDetail(context: Database.shared.container.viewContext,
                                                                                                      exerciseID: exercise.objectID))) {
                            Text(exercise.name ?? "")
                                .font(.body.weight(.semibold))
                                .lineLimit(1)
                                .padding(.vertical, 8)
                        }
                    }
                }, header: {
                    Text(getLetter(for: group))
                })
            }
        }.listStyle(.plain)
            .searchable(text: $searchedText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("All Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExercise.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                EditExerciseView(editExercise: EditExercise())
            }
    }
    
    private var filteredExercises: [Exercise] {
        exercises.filter { searchedText.isEmpty || ($0.name ?? "").lowercased().contains(searchedText.lowercased()) }
    }
    
    private var groupedExercises: [[Exercise]] {
        var result = [[Exercise]]()
        for exercise in filteredExercises {
            if let lastExerciseNameFirstLetter = result.last?.last?.name?.first, let exerciseFirstLetter = exercise.name?.first, lastExerciseNameFirstLetter == exerciseFirstLetter {
                result[result.count - 1].append(exercise)
            } else {
                result.append([exercise])
            }
        }
        return result
    }
    
    private func getLetter(for group: [Exercise]) -> String {
        String(group.first?.name?.first ?? Character(" "))
    }
    
}

struct AllExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        AllExercisesView()
    }
}
