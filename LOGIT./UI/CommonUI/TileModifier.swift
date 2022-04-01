//
//  TileModifier.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 23.03.22.
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

extension View {
    func tileStyle() -> some View {
        modifier(TileModifier())
    }
}

