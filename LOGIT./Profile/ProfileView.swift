//
//  ProfileView.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 01.10.21.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("weightUnit") var weightUnit: WeightUnit = .kg
    
    var body: some View {
        List {
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
