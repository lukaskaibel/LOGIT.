//
//  WorkoutDiaryApp.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 25.06.21.
//

import SwiftUI

@main
struct WorkoutDiaryApp: App {
    
    init() {
        UserDefaults.standard.register(defaults: [
            "weightUnit" : WeightUnit.kg.rawValue
        ])
    }
    
    let database = Database.shared

    var body: some Scene {
        WindowGroup {
            HomeView(context: database.container.viewContext)
                .environment(\.managedObjectContext, database.container.viewContext)
        }
    }
}

