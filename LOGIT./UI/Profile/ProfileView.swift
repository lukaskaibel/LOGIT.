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
            Section(content: {
                Picker(NSLocalizedString("targetPerWeek", comment: ""), selection: $workoutPerWeekTarget) {
                    ForEach(1..<10, id:\.self) { i in
                        Text(String(i)).tag(i)
                    }
                }
            }, footer: {
                Text(NSLocalizedString("targetPerWeekDescription", comment: ""))
            })
            Section(content: {
                Picker(NSLocalizedString("unit", comment: ""), selection: $weightUnit, content: {
                    Text("kg").tag(WeightUnit.kg)
                    Text("lbs").tag(WeightUnit.lbs)
                })
            }, footer: {
                Text(NSLocalizedString("unitDescription", comment: ""))
            })
        }.listStyle(.insetGrouped)
            .navigationTitle(NSLocalizedString("profile", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "")) {
                        dismiss()
                    }.font(.body.weight(.semibold))
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
