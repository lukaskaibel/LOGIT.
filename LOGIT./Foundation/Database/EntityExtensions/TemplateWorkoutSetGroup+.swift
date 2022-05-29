//
//  TemplateWorkoutSetGroup+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation

extension TemplateWorkoutSetGroup {
    
    @objc enum SetType: Int {
        case standard, superSet, dropSet
    }
    
    public var exercise: Exercise? {
        get { exercises?.firstObject as? Exercise }
        set {
            guard let exercise = newValue else { return }
            if exercises?.count == 0 {
                exercises = NSOrderedSet(array: [exercise, exercise])
            } else {
                replaceExercises(at: 0, with: exercise)
            }
        }
    }
    
    public var secondaryExercise: Exercise? {
        get { (exercises?.array as? [Exercise] ?? .emptyList).value(at: 1) }
        set {
            guard let exercise = newValue else { return }
            if exercises?.count == 0 {
                exercises = NSOrderedSet(array: [exercise, exercise])
            } else if exercises?.count == 1 {
                addToExercises(exercise)
            } else {
                replaceExercises(at: 1, with: exercise)
            }
        }
    }
    
    var setType: SetType {
        let firstSet = sets?.array.first
        if let _ = firstSet as? TemplateDropSet {
            return .dropSet
        } else if let _ = firstSet as? TemplateSuperSet {
            return .superSet
        } else {
            return .standard
        }
    }
    
    func index(of set: TemplateSet) -> Int? {
        (sets?.array as? [TemplateSet])?.firstIndex(of: set)
    }
    
}
