//
//  SpiritView.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The flame spirit, crossfading when its mood changes.
struct SpiritView: View {
    enum Mood: String {
        case wave = "spiritWave"
        case focused = "spiritFocused"
        case surprised = "spiritSurprised"
        case cheer = "spiritCheer"
        case sleepy = "spiritSleepy"
    }

    let mood: Mood
    var size: CGFloat = 140

    var body: some View {
        Image(mood.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .id(mood)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: mood)
            .accessibilityHidden(true)
    }
}

/// The spirit with the line it says, shared by the recovery screens.
struct SpiritMessage: View {
    let mood: SpiritView.Mood
    let message: String

    var body: some View {
        VStack(spacing: 6) {
            SpiritView(mood: mood)

            Text(message)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        HStack {
            SpiritView(mood: .wave)
            SpiritView(mood: .cheer)
        }
    }
}
