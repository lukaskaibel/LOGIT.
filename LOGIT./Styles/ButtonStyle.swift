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
            .foregroundColor(.background)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.accentColor)
            .listRowBackground(Color.clear)
            .cornerRadius(20)
    }
}

struct SecondaryBigButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.accentColor.secondaryTranslucentBackground)
            .listRowBackground(Color.clear)
            .cornerRadius(15)
    }
}

struct SelectionButtonModifier: ViewModifier {
    
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(isSelected ? Color.background : .accentColor)
            .padding(3)
            .background(isSelected ? Color.accentColor.opacity(0.9) : .clear)
            .cornerRadius(8)

    }
}

extension View {
    func bigButton() -> some View {
        modifier(BigButtonModifier())
    }
    func secondaryBigButton() -> some View {
        modifier(SecondaryBigButtonModifier())
    }
    func selectionButtonStyle(isSelected: Bool) -> some View {
        modifier(SelectionButtonModifier(isSelected: isSelected))
    }
}
