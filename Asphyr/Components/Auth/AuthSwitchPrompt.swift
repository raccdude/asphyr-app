//
//  AuthSwitchPrompt.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// "Already have an account? LOG IN": one line, stacking only when large
/// text needs it.
struct AuthSwitchPrompt: View {
    let prompt: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 7.5) {
                promptText
                actionButton
            }

            VStack(spacing: 8) {
                promptText
                actionButton
            }
        }
    }

    private var promptText: some View {
        Text(prompt)
            .font(AppTypography.bodySecondary)
            .foregroundStyle(Color.asphyrTextSecondary)
            .multilineTextAlignment(.center)
    }

    private var actionButton: some View {
        Button(action: action) {
            Text(actionTitle)
                .font(AppTypography.bodySecondarySemiBold)
                .foregroundStyle(Color.asphyrAccentPrimary)
                // Grows the tap area to about 44 pt without moving the layout
                .padding(.vertical, 14)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
                .padding(.vertical, -14)
                .padding(.horizontal, -8)
        }
    }
}

#Preview(traits: .dark) {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        AuthSwitchPrompt(prompt: "Already have an account?", actionTitle: "LOG IN") {}
    }
}
