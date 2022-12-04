//
//  Workout+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 01.07.21.
//

import Foundation


extension Workout {
    
    var numberOfSets: Int {
        sets.count
    }
    var numberOfSetGroups: Int {
        setGroups.count
    }
    
    var isEmpty: Bool {
        setGroups.isEmpty
    }
    
    var setGroups: [WorkoutSetGroup] {
        get {
            return (setGroupOrder ?? .emptyList)
                .compactMap { id in (setGroups_?.allObjects as? [WorkoutSetGroup])?.first { setGroup in setGroup.id == id } }
        }
        set {
            setGroupOrder = newValue.map { $0.id! }
            setGroups_ = NSSet(array: newValue)
        }
    }
    
    var exercises: [Exercise] {
        var result = [Exercise]()
        for setGroup in setGroups {
            if let exercise = setGroup.exercise {
                result.append(exercise)
            }
        }
        return result
    }
    
    var sets: [WorkoutSet] {
        var result = [WorkoutSet]()
        for setGroup in setGroups {
            result.append(contentsOf: setGroup.sets)
        }
        return result
    }
    
    var muscleGroups: [MuscleGroup] {
        exercises
            .compactMap { $0.muscleGroup }
    }
    
    var primaryMuscleGroup: MuscleGroup? {
        (muscleGroupOccurances.max { $0.1 < $1.1 })?.0
    }
    
    var muscleGroupOccurances: [(MuscleGroup, Int)] {
        Array(sets
            .reduce(into: [MuscleGroup:Int]()) {
                if let muscleGroup = $1.setGroup?.exercise?.muscleGroup {
                    $0[muscleGroup, default: 0] += 1
                }
                if let muscleGroup = $1.setGroup?.secondaryExercise?.muscleGroup {
                    $0[muscleGroup, default: 0] += 1
                }
            }
            .merging(allMuscleGroupZeroDict, uniquingKeysWith: +)
        ).sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    private var allMuscleGroupZeroDict: [MuscleGroup:Int] {
        MuscleGroup.allCases.reduce(into: [MuscleGroup:Int](), { $0[$1, default: 0] = 0 })
    }
    
    func remove(setGroup: WorkoutSetGroup) {
        setGroups = setGroups.filter { $0 != setGroup }
    }
    
    func index(of setGroup: WorkoutSetGroup) -> Int? {
        setGroups.firstIndex(of: setGroup)
    }
    
    var hasEntries: Bool {
        sets.filter({ !$0.hasEntry }).count != numberOfSets
    }
    
    var allSetsHaveEntries: Bool {
        sets.filter({ !$0.hasEntry }).isEmpty
    }
    
    static func getStandardName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)
        let hour = Calendar.current.component(.hour, from: date)
        let daytime: String
        switch hour {
        case 6..<12: daytime = NSLocalizedString("morning", comment: "")
        case 12..<14: daytime = NSLocalizedString("noon", comment: "")
        case 14..<17: daytime = NSLocalizedString("afternoon", comment: "")
        case 17..<22: daytime = NSLocalizedString("evening", comment: "")
        default: daytime = NSLocalizedString("night", comment: "")
        }
        return "\(weekday) \(daytime) Workout"
    }
    
}
