//
//  PrimaryButtonV2.swift
//  Asphyr
//
//  Created by Angelo Buedo on 10/29/26.
//

import SwiftUI

/// The polished primary button from Figma "05 — Hi-Fi v2".
/// Screens move to this one at a time; once every screen uses it,
/// it replaces `PrimaryButton`.
struct PrimaryButtonV2: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(Self.labelColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Self.gradientTop, Self.gradientBottom],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            // 1 pt white highlight along the top edge
                            .shadow(.inner(color: .white.opacity(0.45), radius: 0, x: 0, y: 1))
                        )
                        .shadow(color: Self.shadowColor, radius: 2, x: 0, y: 2)
                }
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressableButtonStyle())
    }

    // Deliberately not tokenised (see DESIGN-DECISIONS.md)
    private static let gradientTop = Color(red: 125 / 255, green: 255 / 255, blue: 155 / 255)   // #7DFF9B
    private static let gradientBottom = Color(red: 0 / 255, green: 230 / 255, blue: 59 / 255)    // #00E63B
    private static let labelColor = Color(red: 3 / 255, green: 20 / 255, blue: 10 / 255)         // #03140A
    private static let shadowColor = Color(red: 47 / 255, green: 175 / 255, blue: 79 / 255)     // #2FAF4F
}

/// Slight shrink + dim while the button is held down.
private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        PrimaryButtonV2(title: "BEGIN JOURNEY") {}
            .padding(.horizontal, 20)
    }
}
