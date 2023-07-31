//
//  TemplateDropSet+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 15.05.22.
//

import Foundation

extension TemplateDropSet {

    public func addDrop() {
        repetitions?.append(0)
        weights?.append(0)
    }

    public func removeLastDrop() {
        if repetitions?.count ?? 0 > 1 && weights?.count ?? 0 > 1 {
            repetitions?.removeLast()
            weights?.removeLast()
        }
    }

    // MARK: Overrides from TemplateSet

    override public var hasEntry: Bool {
        (repetitions?.reduce(0, +) ?? 0) + (weights?.reduce(0, +) ?? 0) > 0
    }

}
