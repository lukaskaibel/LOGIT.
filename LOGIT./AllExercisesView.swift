//
//  AllExercisesView.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 01.10.21.
//

import SwiftUI

struct AllExercisesView: View {
    
    @FetchRequest(entity: Exercise.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: false)]) var exercises: FetchedResults<Exercise>
    
    @State var searchedText: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(exercises.filter { searchedText.isEmpty || $0.name?.contains(searchedText) ?? false } ) { exercise in
                    Text(exercise.name ?? "No name")
                }
            }
        }.searchable(text: $searchedText)
    }
    
}

struct AllExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        AllExercisesView()
    }
}
