//
//  TemplateSetGroup+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 02.04.22.
//

import Foundation

extension TemplateSetGroup {
    
    @objc enum SetType: Int {
        case standard, superSet, dropSet
    }
    
    public var sets: [TemplateSet] {
        get {
            return (setOrder ?? .emptyList)
                .compactMap { id in (sets_?.allObjects as? [TemplateSet])?.first { $0.id == id } }
        }
        set {
            setOrder = newValue.map { $0.id! }
            sets_ = NSSet(array: newValue)
        }
    }
    
    private var exercises: [Exercise] {
        get {
            return (exerciseOrder ?? .emptyList)
                .compactMap { id in (exercises_?.allObjects as? [Exercise])?.first { $0.id == id } }
        }
        set {
            exerciseOrder = newValue.map { $0.id! }
            exercises_ = NSSet(array: newValue)
        }
    }
    
    public var exercise: Exercise? {
        get { exercises.first }
        set {
            guard let exercise = newValue else { return }
            if exercises.count == 0 {
                exercises = [exercise, exercise]
            } else {
                exercises.replaceValue(at: 0, with: exercise)
            }
        }
    }
    
    public var secondaryExercise: Exercise? {
        get { exercises.value(at: 1) }
        set {
            guard let exercise = newValue else { return }
            if exercises.count == 0 {
                exercises = [exercise, exercise]
            } else if exercises.count == 1 {
                exercises.append(exercise)
            } else {
                exercises.replaceValue(at: 1, with: exercise)
            }
        }
    }
    
    var setType: SetType {
        let firstSet = sets.first
        if let _ = firstSet as? TemplateDropSet {
            return .dropSet
        } else if let _ = firstSet as? TemplateSuperSet {
            return .superSet
        } else {
            return .standard
        }
    }
    
    func index(of set: TemplateSet) -> Int? {
        sets.firstIndex(of: set)
    }
    
}
