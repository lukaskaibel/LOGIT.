//
//  TileStyle.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 27.07.23.
//

import SwiftUI

struct TileModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.secondaryBackground)
            .cornerRadius(20)
   }    
}

struct SecondaryTileModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.tertiaryBackground)
            .cornerRadius(15)
   }
}

extension View {
    func tileStyle() -> some View {
        modifier(TileModifier())
    }
    func secondaryTileStyle() -> some View {
        modifier(SecondaryTileModifier())
    }
}

struct TileStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello World")
                .padding()
                .tileStyle()
            Text("Hello World")
                .padding()
                .secondaryTileStyle()
                .padding()
                .tileStyle()
        }
    }
}
