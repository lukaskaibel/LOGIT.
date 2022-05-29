//
//  TemplateSuperSet+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 25.05.22.
//

import Foundation

extension TemplateSuperSet {
    
    public var secondaryExercise: Exercise? {
        setGroup?.secondaryExercise
    }
    
    //MARK: Overrides from TemplateSet
    
    public override var hasEntry: Bool {
        repetitionsFirstExercise + repetitionsSecondExercise + weightFirstExercise + weightSecondExercise > 0
    }
    
}
