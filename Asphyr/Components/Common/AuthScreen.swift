//
//  AuthScreen.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The layout shared by auth screens: background, pinned `AuthTopBar`, and
/// content that fills the screen at the default text size, and only scrolls
/// when the keyboard or larger text needs more room.
struct AuthScreen<Content: View>: View {
    var showsBackButton: Bool = true
    var onboardingStep: Int?
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView {
                    content
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .authTopBar(showsBackButton: showsBackButton, onboardingStep: onboardingStep)
    }
}
