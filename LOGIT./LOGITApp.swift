//
//  LOGITApp.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 25.06.21.
//

import SwiftUI

@main
struct LOGIT: App {
    
    enum TabType: Hashable {
        case home, templates, startWorkout, exercises, settings
    }
    
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
    @State private var selectedTab: TabType = .home

    var body: some Scene {
        WindowGroup {
            if setupDone {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(TabType.home)
                    NavigationStack {
                        TemplateListView()
                    }
                    .tabItem { Label(NSLocalizedString("templates", comment: ""), systemImage: "list.bullet.rectangle.portrait") }
                    .tag(TabType.templates)
                    NavigationStack {
                        StartWorkoutView()
                    }
                    .tabItem { Label(NSLocalizedString("startWorkout", comment: ""), systemImage: "plus") }
                    .tag(TabType.startWorkout)
                    NavigationStack {
                        AllExercisesView()
                    }
                    .tabItem { Label(NSLocalizedString("exercises", comment: ""), image: "LOGIT") }
                    .tag(TabType.exercises)
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem { Label(NSLocalizedString("settings", comment: ""), systemImage: "gear") }
                    .tag(TabType.settings)
                }
                .environmentObject(database)
                .preferredColorScheme(.dark)
            } else {
                FirstStartView()
                    .environmentObject(database)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

