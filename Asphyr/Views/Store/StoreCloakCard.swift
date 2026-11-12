//
//  StoreCloakCard.swift
//  Asphyr
//

import SwiftUI

/// A cloak for sale, shown on the user's own character, so they see themselves in it.
struct StoreCloakCard: View {
    let cloak: CharacterCloak
    let price: Int
    let onBuy: () -> Void

    @Environment(OnboardingProfile.self) private var profile
    @Environment(QuestStore.self) private var questStore

    private var isOwned: Bool {
        questStore.owns(cloak.rawValue)
    }

    private var isWorn: Bool {
        profile.cloak == cloak
    }

    private var canAfford: Bool {
        questStore.embers >= price
    }

    var body: some View {
        VStack(spacing: 0) {
            CharacterArt(color: profile.color, archetype: profile.archetype, cloak: cloak)
                .frame(width: 104, height: 104)
                .accessibilityHidden(true)

            Text(cloak.rawValue.uppercased())
                .font(AppTypography.sectionTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .padding(.top, 8)

            Text(isOwned ? "Owned" : "Cloak")
                .font(AppTypography.captionRegular)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 2)

            actionButton
                .padding(.top, 12)
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .settingsCard()
        .overlay {
            if isWorn {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 1.5)
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if isWorn {
            label("WEARING", color: .asphyrAccentPrimary, isFilled: false)
                .accessibilityLabel("\(cloak.rawValue) cloak, wearing")
        } else if isOwned {
            Button {
                profile.cloak = cloak
            } label: {
                label("WEAR", color: .asphyrAccentPrimary, isFilled: true)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Wear the \(cloak.rawValue) cloak")
        } else {
            // Stays tappable when short, so the tap can say how many more are needed
            Button(action: onBuy) {
                HStack(spacing: 6) {
                    Image("iconEmber")
                    Text("\(price)")
                }
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrWarning)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(Color.asphyrWarning.opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(Color.asphyrWarning.opacity(0.4), lineWidth: 1)
                }
                .opacity(canAfford ? 1 : 0.5)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Buy the \(cloak.rawValue) cloak for \(price) Embers")
        }
    }

    private func label(_ text: String, color: Color, isFilled: Bool) -> some View {
        Text(text)
            .font(AppTypography.captionMedium)
            .foregroundStyle(isFilled ? Color.asphyrBackground : color)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(isFilled ? color : color.opacity(0.12), in: Capsule())
    }
}
