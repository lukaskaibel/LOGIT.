//
//  WorkoutDiaryApp.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 25.06.21.
//

import SwiftUI

@main
struct WorkoutDiaryApp: App {
    
    @AppStorage("setupDone") var setupDone: Bool = false
    
    init() {
        UserDefaults.standard.register(defaults: [
            "weightUnit" : WeightUnit.kg.rawValue,
            "workoutPerWeekTarget" : 3,
            "setupDone" : false
        ])
        //FirstStartView Test
        UserDefaults.standard.set(false, forKey: "setupDone")
    }
    
    let database = Database.shared

    var body: some Scene {
        WindowGroup {
            if setupDone {
                HomeView(context: database.container.viewContext)
                    .environment(\.managedObjectContext, database.container.viewContext)
            } else {
                FirstStartView()
            }
        }
    }
}

