//
//  Styles.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 08.04.22.
//

import SwiftUI

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

struct KeyboardToolbarButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.light))
            .foregroundColor(.primary)
            .frame(width: 70)
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
                .font(.title2)
                .foregroundColor(.placeholder)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct SwipeDownModifier: ViewModifier {
    let onSwipeDown: () -> Void

    func body(content: Content) -> some View {
        content.gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { value in
                    let swipeDistance = value.translation.height
                    if swipeDistance > 0 {
                        onSwipeDown()
                    }
                }
        )
    }
}

extension View {
    
    func cellTileStyle() -> some View {
        modifier(CellTileModifier())
    }
    
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderModifier())
    }
    
    func keyboardToolbarButtonStyle() -> some View {
        modifier(KeyboardToolbarButtonModifier())
    }
    
    func emptyPlaceholder<Items: Collection, PlaceholderView: View>(_ items: Items, _ placeholder: @escaping () -> PlaceholderView) -> some View {
        modifier(EmptyPlaceholderModifier(items: items, placeholder: AnyView(placeholder())))
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func onSwipeDown(perform action: @escaping () -> Void) -> some View {
        self.modifier(SwipeDownModifier(onSwipeDown: action))
    }
}
