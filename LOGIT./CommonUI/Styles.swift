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

struct CellTileModifier: ViewModifier {
    func body(content: Content) -> some View {
       content
            .padding(10)
            .background(Color.secondaryBackground)
            .cornerRadius(20)
   }
}

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.bold))
            .foregroundColor(.label)
            .padding(.vertical, 10)
            .textCase(.none)
    }
}

struct ListButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body.weight(.bold))
            .foregroundColor(.accentColor)
            .padding(10)
            .listRowBackground(Color.accentColor.secondaryTranslucentBackground)
    }
}

struct EmptyPlaceholderModifier<Items: Collection>: ViewModifier {
    let items: Items
    let placeholder: AnyView

    @ViewBuilder func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
                .font(.title3)
                .foregroundColor(.placeholder)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }
}

extension View {
    func tileStyle() -> some View {
        modifier(TileModifier())
    }
    
    func cellTileStyle() -> some View {
        modifier(CellTileModifier())
    }
    
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderModifier())
    }
    
    func listButton() -> some View {
        modifier(ListButtonModifier())
    }
    
    func emptyPlaceholder<Items: Collection, PlaceholderView: View>(_ items: Items, _ placeholder: @escaping () -> PlaceholderView) -> some View {
        modifier(EmptyPlaceholderModifier(items: items, placeholder: AnyView(placeholder())))
    }
}
