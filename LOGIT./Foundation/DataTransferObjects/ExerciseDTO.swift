//
//  Exercise+Decodable.swift
//  LOGITTests
//
//  Created by Lukas Kaibel on 04.10.23.
//

import Foundation

struct ExerciseDTO: Decodable {
    var name: String?
    var muscleGroup: MuscleGroup?
}
