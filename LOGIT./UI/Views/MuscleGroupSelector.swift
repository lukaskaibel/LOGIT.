//
//  MuscleGroupSelector.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 21.04.22.
//

import SwiftUI

struct MuscleGroupSelector: View {

    @Binding var selectedMuscleGroup: MuscleGroup?
    let canBeNil: Bool

    init(selectedMuscleGroup: Binding<MuscleGroup?>, canBeNil: Bool = true) {
        self._selectedMuscleGroup = selectedMuscleGroup
        self.canBeNil = canBeNil
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if canBeNil {
                    Button(NSLocalizedString("all", comment: "")) {
                        selectedMuscleGroup = nil
                    }
                    .buttonStyle(CapsuleButtonStyle(isSelected: selectedMuscleGroup == nil))
                }
                ForEach(MuscleGroup.allCases) { muscleGroup in
                    Button(muscleGroup.description) {
                        selectedMuscleGroup = muscleGroup
                    }
                    .buttonStyle(
                        CapsuleButtonStyle(
                            color: muscleGroup.color,
                            isSelected: selectedMuscleGroup == muscleGroup
                        )
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MuscleGroupSelector_Previews: PreviewProvider {
    static var previews: some View {
        MuscleGroupSelector(selectedMuscleGroup: .constant(.chest))
    }
}
