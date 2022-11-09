//
//  MuscleGroupSelector.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 21.04.22.
//

import SwiftUI

struct MuscleGroupSelector: View {
    
    @Binding var selectedMuscleGroup: MuscleGroup?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(NSLocalizedString("all", comment: "")) { selectedMuscleGroup = nil }
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .foregroundColor(selectedMuscleGroup == nil ? .white : .accentColor)
                    .background(selectedMuscleGroup == nil ? Color.accentColor : .accentColorBackground)
                    .clipShape(Capsule())
                ForEach(MuscleGroup.allCases) { muscleGroup in
                    Button(muscleGroup.description) { selectedMuscleGroup = muscleGroup }
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .foregroundColor(selectedMuscleGroup == muscleGroup ? .white : muscleGroup.color)
                        .background(muscleGroup.color.opacity(selectedMuscleGroup == muscleGroup ? 1 : 0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

struct MuscleGroupSelector_Previews: PreviewProvider {
    static var previews: some View {
        MuscleGroupSelector(selectedMuscleGroup: .constant(.chest))
    }
}
