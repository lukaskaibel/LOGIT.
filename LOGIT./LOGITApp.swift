//
//  LOGITApp.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 25.06.21.
//

import SwiftUI

@main
struct LOGIT: App {
    
    @AppStorage("setupDone") var setupDone: Bool = false
        
    init() {
        UserDefaults.standard.register(defaults: [
            "weightUnit" : WeightUnit.kg.rawValue,
            "workoutPerWeekTarget" : 3,
            "setupDone" : false
        ])
        //Start App in other language
//        UserDefaults.standard.set(["eng"], forKey: "AppleLanguages")
//        UserDefaults.standard.synchronize()
        //FirstStartView Test
//        UserDefaults.standard.set(false, forKey: "setupDone")
        
        //Fixes issue with wrong Accent Color in Alerts
        UIView.appearance().tintColor = UIColor(named: "AccentColor")
    }
    
    @StateObject private var database = Database.shared

    var body: some Scene {
        WindowGroup {
            if setupDone {
                TabView {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house.fill") }
                    NavigationStack {
                        TemplateListView()
                    }.tabItem { Label(NSLocalizedString("templates", comment: ""), systemImage: "list.bullet.rectangle.portrait") }
                    NavigationStack {
                        StartWorkoutView()
                    }.tabItem { Label(NSLocalizedString("startWorkout", comment: ""), systemImage: "plus") }
                    NavigationStack {
                        AllExercisesView()
                    }.tabItem { Label(NSLocalizedString("exercises", comment: ""), image: "LOGIT") }
                    NavigationStack {
                        ProfileView()
                    }.tabItem { Label(NSLocalizedString("settings", comment: ""), systemImage: "gear") }
                }.environment(\.managedObjectContext, database.context)
                    .environmentObject(database)
            } else {
                FirstStartView()
            }
        }
    }
}

