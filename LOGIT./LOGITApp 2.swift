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

    // MARK: - AppStorage

    @AppStorage("setupDone") var setupDone: Bool = false

    // MARK: - State

    @StateObject private var database = Database.shared
    @State private var selectedTab: TabType = .home

    // MARK: - Init

    init() {
        UserDefaults.standard.register(defaults: [
            "weightUnit": WeightUnit.kg.rawValue,
            "workoutPerWeekTarget": 3,
            "setupDone": false,
        ])
        //Fixes issue with wrong Accent Color in Alerts
        UIView.appearance().tintColor = UIColor(named: "AccentColor")

        // MARK: - Test Methods
        // testLanguage()
        // testFirstStart()
    }

    // MARK: - Body

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
                    .tabItem {
                        Label(
                            NSLocalizedString("templates", comment: ""),
                            systemImage: "list.bullet.rectangle.portrait"
                        )
                    }
                    .tag(TabType.templates)
                    NavigationStack {
                        StartWorkoutView()
                    }
                    .tabItem {
                        Label(NSLocalizedString("startWorkout", comment: ""), systemImage: "plus")
                    }
                    .tag(TabType.startWorkout)
                    NavigationStack {
                        AllExercisesView()
                    }
                    .tabItem { Label(NSLocalizedString("exercises", comment: ""), image: "LOGIT") }
                    .tag(TabType.exercises)
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label(NSLocalizedString("settings", comment: ""), systemImage: "gear")
                    }
                    .tag(TabType.settings)
                }
                .environmentObject(database)
                .environment(\.goHome, { selectedTab = .home })
            } else {
                FirstStartView()
                    .environmentObject(database)
            }
        }
    }

    // MARK: - Methods / Computed Properties

    func testLanguage() {
        UserDefaults.standard.set(["eng"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    func testFirstStart() {
        UserDefaults.standard.set(false, forKey: "setupDone")
    }

}

// MARK: - EnvironmentValues/Keys

struct GoHomeKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var goHome: () -> Void {
        get { self[GoHomeKey.self] }
        set { self[GoHomeKey.self] = newValue }
    }
}
