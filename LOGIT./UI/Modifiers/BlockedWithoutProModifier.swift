//
//  BlockedWithoutProModifier.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 27.09.23.
//

import SwiftUI

struct BlockedWithoutProModifier: ViewModifier {
    
    @EnvironmentObject private var purchaseManager: PurchaseManager

    let blocked: Bool

    @State private var isShowingUpgradeToProScreen = false

    func body(content: Content) -> some View {
        if !purchaseManager.hasUnlockedPro && blocked {
            content
                .overlay {
                    Color.black.opacity(0.2)
                }
                .blur(radius: 5)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .allowsHitTesting(false)
                .overlay {
                    Button {
                        isShowingUpgradeToProScreen = true
                    } label: {
                        HStack {
                            Text("Available with")
                            LogitProLogo()
                                .environment(\.colorScheme, .light)
                        }
                    }
                    .buttonStyle(CapsuleButtonStyle())
                    .shadow(radius: 15)
                }
                .sheet(isPresented: $isShowingUpgradeToProScreen) {
                    NavigationStack {
                        UpgradeToProScreen()
                    }
                }
        } else {
            content
        }
    }

}

extension View {

    func isBlockedWithoutPro(_ blocked: Bool = true) -> some View {
        self.modifier(BlockedWithoutProModifier(blocked: blocked))
    }

}
