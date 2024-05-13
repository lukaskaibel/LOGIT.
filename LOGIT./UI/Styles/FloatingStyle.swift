//
//  FloatingStyle.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 13.05.24.
//

import SwiftUI

struct FloatingStyleModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 10)
    }
}

extension View {
    func floatingStyle() -> some View {
        modifier(FloatingStyleModifier())
    }
}
