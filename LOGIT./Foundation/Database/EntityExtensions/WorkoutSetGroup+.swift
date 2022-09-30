//
//  WorkoutSetGroup+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.03.22.
//

import Foundation


extension WorkoutSetGroup {
    
    public enum SetType: Int {
        case standard, superSet, dropSet
    }
    
    var sets: [WorkoutSet] {
        get {
            return (setOrder ?? .emptyList)
                .compactMap { id in (sets_?.allObjects as? [WorkoutSet])?.first { $0.id == id } }
        }
        set {
            setOrder = newValue.map { $0.id! }
            sets_ = NSSet(array: newValue)
        }
    }
    
    public var isEmpty: Bool {
        sets.isEmpty
    }
    
    public var numberOfSets: Int {
        sets.count
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
    
    public var setType: SetType {
        let firstSet = sets.first
        if let _ = firstSet as? DropSet {
            return .dropSet
        } else if let _ = firstSet as? SuperSet {
            return .superSet
        } else {
            return .standard
        }
    }
    
    public subscript(index: Int) -> WorkoutSet {
        get { sets[index] }
    }
    
    public func index(of set: WorkoutSet) -> Int? {
        sets.firstIndex(of: set)
    }
    
}
