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

extension View {
    func tileStyle() -> some View {
        modifier(TileModifier())
    }
}

struct TileStyle_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
            .padding()
            .tileStyle()
    }
}
