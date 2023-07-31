//
//  TemplateSet+.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 21.05.22.
//

import Foundation

extension TemplateSet {

    @objc public var hasEntry: Bool {
        fatalError("TemplateSet+: hasEntry must be implemented in subclass of TemplateSet")
    }

    public var exercise: Exercise? {
        setGroup?.exercise
    }

}
