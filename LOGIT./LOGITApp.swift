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
    
    let database = Database.shared

    var body: some Scene {
        WindowGroup {
            if setupDone {
                TabView {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house") }
                    NavigationView {
                        ProfileView()
                    }.tabItem { Label(NSLocalizedString("profile", comment: ""), systemImage: "person.fill") }
                }.environment(\.managedObjectContext, database.context)
            } else {
                FirstStartView()
            }
        }
    }
}

