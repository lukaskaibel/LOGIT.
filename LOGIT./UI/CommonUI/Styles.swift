//
//  Styles.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 08.04.22.
//

import SwiftUI

struct TileModifier: ViewModifier {
    func body(content: Content) -> some View {
       content
            .padding()
            .background(Color.secondaryBackground)
            .cornerRadius(20)
   }
}

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.bold))
            .foregroundColor(.label)
            .padding(.vertical, 8)
    }
}

extension View {
    func tileStyle() -> some View {
        modifier(TileModifier())
    }
    
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderModifier())
    }
}
