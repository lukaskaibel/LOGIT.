//
//  Color+.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 12.06.21.
//

import SwiftUI


extension Color {
    
    static var label: Color { Color(UIColor.label) }
    static var secondaryLabel: Color { Color(UIColor.secondaryLabel) }
    static var tertiaryLabel: Color { Color(UIColor.tertiaryLabel) }
    
    static var separator: Color { Color(UIColor.separator) }
    
    static var background: Color { Color(UIColor.systemBackground) }
    static var secondaryBackground: Color { Color(UIColor.secondarySystemBackground) }
    static var tertiaryBackground: Color { Color(UIColor.tertiarySystemBackground) }
    
    static var fill: Color { Color(UIColor.systemFill) }
    static var secondaryFill: Color { Color(UIColor.secondarySystemFill) }
    static var tertiaryFill: Color { Color(UIColor.tertiarySystemFill) }
    
    static var shadow: Color { Color.black.opacity(0.2) }

    static var accentColorBackground: Color { Color.accentColor.opacity(0.1) }

}
