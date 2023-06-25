//
//  FirstStartView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 21.03.22.
//

import SwiftUI

struct FirstStartView: View {
    
    private enum SetupStage {
        case start, weightUnit, weeklyTarget
    }
    
    // MARK: - AppStorage
    
    @AppStorage("weightUnit") var weightUnit: WeightUnit = .kg
    @AppStorage("workoutPerWeekTarget") var weeklyWorkoutTarget: Int = 3
    @AppStorage("setupDone") var setupDone: Bool = false
    
    // MARK: - State
    
    @State private var setupStage: SetupStage = .start
    @State private var useStandardExercises: Bool = true
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment:.leading) {
                    Text(NSLocalizedString("welcomeTo", comment: ""))
                        .font(.title2.weight(.medium))
                    Text("LOGIT.")
                        .font(.system(size: 50, weight: .bold, design: .default))
                }
                Spacer()
            }.padding(.top, 30)
            Spacer()
            if setupStage == .start {
                VStack {
                    Text("\(NSLocalizedString("letsGetStarted", comment: "")) 💪")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(NSLocalizedString("letsGetStartedDescription", comment: ""))
                        .foregroundColor(.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else if setupStage == .weightUnit {
                VStack {
                    Text("\(NSLocalizedString("weightUnit", comment: "")) ⚖️")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(NSLocalizedString("weightUnitDescription", comment: ""))
                        .foregroundColor(.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Picker(NSLocalizedString("weightUnit", comment: ""), selection: $weightUnit, content: {
                        ForEach([WeightUnit.kg, .lbs]) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }).pickerStyle(.wheel)
                }.padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(20)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                VStack {
                    Text("\(NSLocalizedString("weeklyTarget", comment: "")) 🗓")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(NSLocalizedString("weeklyTargetDescription", comment: ""))
                        .foregroundColor(.secondaryLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Picker(NSLocalizedString("weeklyTarget", comment: ""), selection: $weeklyWorkoutTarget, content: {
                        ForEach(1..<10, id:\.self) { i in
                            Text(String(i)).tag(i)
                        }
                    }).pickerStyle(.wheel)
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
                        setupDone = true
                    }
                }
            }) {
                HStack {
                    Image(systemName: setupStage == .weeklyTarget ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    Text(setupStage == .start ? NSLocalizedString("startSetup", comment: "") : setupStage == .weeklyTarget ? NSLocalizedString("finishSetup", comment: "") : NSLocalizedString("continue", comment: ""))
                }.foregroundColor(.accentColor)
                    .font(.title3.weight(.bold))
            }.frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(15)
                .padding(.bottom, 50)
        }
        .padding()
    }

}

struct FirstStartView_Previews: PreviewProvider {
    static var previews: some View {
        FirstStartView()
    }
}
