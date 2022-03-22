//
//  ProfileView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 01.10.21.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    private var database: Database = Database.shared
    
    @AppStorage("weightUnit") var weightUnit: WeightUnit = .kg
    @AppStorage("workoutPerWeekTarget") var workoutPerWeekTarget: Int = 3
    
    var body: some View {
        List {
            NavigationLink(destination: AllExercisesView()) {
                Section(content: {
                    VStack(alignment: .leading) {
                        Text("All Exercises")
                        Text("\(database.numberOfExercises) exercise\(database.numberOfExercises == 1 ? "" : "s")")
                            .foregroundColor(.secondaryLabel)
                    }.padding(.vertical, 3)
                })
            }
            Section(content: {
                Picker("Target per week", selection: $workoutPerWeekTarget) {
                    ForEach(1..<10, id:\.self) { i in
                        Text(String(i)).tag(i)
                    }
                }
            }, footer: {
                Text("Select your workout target per week.")
            })
            Section(content: {
                Picker("Unit", selection: $weightUnit, content: {
                    Text("KG").tag(WeightUnit.kg)
                    Text("LBS").tag(WeightUnit.lbs)
                })
            }, footer: {
                Text("Select the unit you want to use. Any previous entries will be converted on change.")
            })
        }.listStyle(.grouped)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }.font(.body.weight(.bold))
                }
            }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
