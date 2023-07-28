//
//  Button.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 28.07.23.
//

import SwiftUI

struct BigButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.accentColor.secondaryTranslucentBackground)
            .listRowBackground(Color.clear)
            .cornerRadius(20)
    }
}

extension View {
    func bigButton() -> some View {
        modifier(BigButtonModifier())
    }
}
