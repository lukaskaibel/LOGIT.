//
//  FirstStartView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 21.03.22.
//

import SwiftUI

struct FirstStartView: View {
    
    private enum SetupStage {
        case start, weightUnit, weeklyTarget, standardExercises
    }
    
    @AppStorage("weightUnit") var weightUnit: WeightUnit = .kg
    @AppStorage("workoutPerWeekTarget") var weeklyWorkoutTarget: Int = 3
    @AppStorage("setupDone") var setupDone: Bool = false
    
    @State private var setupStage: SetupStage = .start
    @State private var useStandardExercises: Bool = true
    @State private var setupFinished = false
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment:.leading) {
                    Text("Welcome to")
                        .font(.title2.weight(.medium))
                    Text("LOGIT.")
                        .font(.system(size: 50, weight: .bold, design: .default))
                }
                Spacer()
            }.padding(.top, 30)
            Spacer()
            if setupStage == .start {
                VStack {
                    Text("Let's get started 💪")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Before you can start working out we need to do a quick setup to optimise your experience.")
                        .foregroundColor(.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else if setupStage == .weightUnit {
                VStack {
                    Text("Weight Unit ⚖️")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Select the unit you want to use throughout the app.")
                        .foregroundColor(.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Picker("Weight Unit", selection: $weightUnit, content: {
                        ForEach([WeightUnit.kg, .lbs]) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }).pickerStyle(.wheel)
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else if setupStage == .weeklyTarget {
                VStack {
                    Text("Weekly Target 🗓")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Select how many workouts you want to do per week.")
                        .foregroundColor(.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Picker("Weekly Target", selection: $weeklyWorkoutTarget, content: {
                        ForEach(1..<10, id:\.self) { i in
                            Text(String(i)).tag(i)
                        }
                    }).pickerStyle(.wheel)
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                VStack {
                    Text("Default Exercises")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Do you want to use the default exercise library?")
                        .foregroundColor(.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Toggle(isOn: $useStandardExercises, label: {
                        VStack(alignment: .leading) {
                            Text("Use Default Exercises")
                            Text("(recommended)")
                                .foregroundColor(.secondaryLabel)
                                .font(.caption)
                        }
                    })
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
            Spacer()
            Button(action: {
                switch setupStage {
                case .start:
                    withAnimation {
                        setupStage = .weightUnit
                    }
                case .weightUnit:
                    withAnimation {
                        setupStage = .weeklyTarget
                    }
                case .weeklyTarget:
                    withAnimation {
                        setupStage = .standardExercises
                    }
                case .standardExercises:
                    if useStandardExercises {
                        addDefaultExercises()
                    }
                    setupDone = true
                    setupFinished = true
                }
            }) {
                HStack {
                    Image(systemName: setupStage == .standardExercises ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    Text(setupStage == .start ? "Start Setup" : setupStage == .standardExercises ? "Finish Setup" : "Continue")
                }.foregroundColor(.accentColor)
                    .font(.title3.weight(.bold))
            }.frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(15)
                .padding(.bottom, 50)
        }.padding()
            .fullScreenCover(isPresented: $setupFinished) {
                HomeView(context: Database.shared.container.viewContext)
                    .environment(\.managedObjectContext, Database.shared.container.viewContext)
            }
    }
    
    private func addDefaultExercises() {
        for exerciseName in Exercise.defaultExerciseNames {
            Database.shared.newExercise(name: exerciseName)
        }
        Database.shared.save()
    }
    
}

struct FirstStartView_Previews: PreviewProvider {
    static var previews: some View {
        FirstStartView()
    }
}
