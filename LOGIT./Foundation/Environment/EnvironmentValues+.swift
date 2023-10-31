//
//  EnvironmentValues+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 29.07.23.
//

import SwiftUI

public var privacyPolicyVersion = 2

private struct WorkoutSetTemplateSetDictionaryKey: EnvironmentKey {
    static let defaultValue: [WorkoutSet: TemplateSet] = [WorkoutSet: TemplateSet]()
}

private struct SetWorkoutEndDateKey: EnvironmentKey {
    static let defaultValue: (Date) -> Void = { _ in }
}

private struct CanEditKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var workoutSetTemplateSetDictionary: [WorkoutSet: TemplateSet] {
        get { self[WorkoutSetTemplateSetDictionaryKey.self] }
        set { self[WorkoutSetTemplateSetDictionaryKey.self] = newValue }
    }
    var setWorkoutEndDate: (Date) -> Void {
        get { self[SetWorkoutEndDateKey.self] }
        set { self[SetWorkoutEndDateKey.self] = newValue }
    }
    var canEdit: Bool {
        get { self[CanEditKey.self] }
        set { self[CanEditKey.self] = newValue }
    }
}
