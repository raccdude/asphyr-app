//
//  RewardView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

/// Shown over the app when a quest is completed.
struct RewardView: View {
    let completion: QuestCompletion

    @Environment(OnboardingProfile.self) private var profile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openCharacter) private var openCharacter

    @State private var isRevealed = false
    @State private var isShowingUnlockedReward = false

    private var quest: Quest {
        completion.quest
    }

    /// Login skips onboarding until real accounts exist, so the name can be empty.
    private var displayName: String {
        profile.name.isEmpty ? "Traveler" : profile.name
    }

    private var clearedText: String {
        if !quest.steps.isEmpty {
            return quest.steps.count == 1 ? "Your 1 step is done" : "All \(quest.steps.count) steps done"
        }

        let minutes = max(1, Int(completion.elapsed / 60))
        return minutes == 1 ? "Quest cleared in 1 minute" : "Quest cleared in \(minutes) minutes"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                spiritMessage

                Text("QUEST COMPLETE")
                    .font(AppTypography.screenTitle)
                    .foregroundStyle(Color.asphyrAccentPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 16)

                Text(quest.title)
                    .font(AppTypography.subheading)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .padding(.top, 3)

                Text("REWARDS")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .padding(.top, 32)

                lootCards
                    .frame(maxWidth: .infinity)
                    .padding(.top, 17)

                if quest.isBonusReward {
                    Text("Small progress is still progress.")
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                }

                if completion.didLevelUp {
                    levelUpBanner
                        .padding(.top, 29)
                }

                experience
                    .padding(.top, completion.didLevelUp ? 14 : 29)

                if !completion.newCloaks.isEmpty {
                    unlockedReward
                        .padding(.top, 20)

                    if isShowingUnlockedReward {
                        Button("VIEW IN CHARACTER") {
                            openCharacter()
                            dismiss()
                        }
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrAccentPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PrimaryButtonV2(title: "CONTINUE") {
                dismiss()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(Color.asphyrBackground)
        }
        .background(Color.asphyrBackground.ignoresSafeArea())
        .sensoryFeedback(.success, trigger: isRevealed)
        .onAppear {
            isRevealed = true
        }
    }

    private var spiritMessage: some View {
        HStack(spacing: 2) {
            SpiritView(mood: .cheer, size: 104)

            VStack(alignment: .leading, spacing: 4) {
                Text("Nice work, \(displayName)!")
                    .font(AppTypography.bodySemiBold)
                    .foregroundStyle(Color.asphyrTextPrimary)

                Text(clearedText)
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.asphyrSurfaceElevated,
                in: UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 4,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 16
                )
            )
        }
        // The spirit's art has space around it, so it sits just past the margin
        .padding(.leading, -6)
    }

    /// The XP card sits in the middle, with up to two attributes tilted beside it.
    private var lootCards: some View {
        let attributes = Array(quest.attributeRewards.prefix(2))

        return HStack(spacing: 11) {
            if let attribute = attributes.first {
                lootCard(
                    value: attribute.value,
                    label: attribute.name,
                    iconName: attribute.iconName,
                    color: .asphyrAccentPrimary,
                    delay: 0.6
                )
                .rotationEffect(.degrees(6))
                .offset(y: 5)
            }

            lootCard(
                value: quest.xpReward,
                label: "XP",
                iconName: "iconQuestReward",
                color: .asphyrWarning,
                isLarge: true,
                delay: 0.15
            )

            if attributes.count > 1 {
                lootCard(
                    value: attributes[1].value,
                    label: attributes[1].name,
                    iconName: attributes[1].iconName,
                    color: .asphyrAccentPrimary,
                    delay: 1.05
                )
                .rotationEffect(.degrees(-6))
            }
        }
    }

    private func lootCard(
        value: Int,
        label: String,
        iconName: String,
        color: Color,
        isLarge: Bool = false,
        delay: Double
    ) -> some View {
        VStack(spacing: 0) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.2), in: Circle())
                .accessibilityHidden(true)

            Text("+\(value)")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(color)
                .padding(.top, 14)

            Text(label)
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 4)
        }
        .padding(.horizontal, 4)
        .padding(.top, 22)
        .frame(width: isLarge ? 120 : 104, height: isLarge ? 164 : 146, alignment: .top)
        .background(Color.asphyrSurface)
        .overlay(alignment: .top) {
            color.frame(height: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(color, lineWidth: 1.5)
        }
        .accessibilityElement(children: .combine)
        // The one moment of motion: each card fades and pops in, XP first
        .scaleEffect(isRevealed ? 1 : 0.6)
        .opacity(isRevealed ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(delay), value: isRevealed)
    }

    private var levelUpBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("LEVEL UP")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(Color.asphyrAccentPrimary)

                Text("Level \(completion.levelBefore) → Level \(completion.levelAfter)")
                    .font(AppTypography.bodySemiBold)
                    .foregroundStyle(Color.asphyrTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("LV \(completion.levelAfter)")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrBackground)
                .fixedSize()
                .padding(.horizontal, 12)
                .frame(minWidth: 52, minHeight: 32)
                .background(Color.asphyrAccentPrimary, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 64)
        .background(Color.asphyrAccentPrimary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 1)
        }
    }

    private var experience: some View {
        VStack(spacing: 5) {
            HStack {
                Text("EXPERIENCE")
                Spacer()
                Text("\(completion.xpIntoLevel) / \(completion.xpForLevel) XP")
            }
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrTextSecondary)

            XPBar(progress: CGFloat(completion.xpIntoLevel) / CGFloat(completion.xpForLevel))
        }
    }

    /// Expands in place, with no separate screen.
    private var unlockedReward: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingUnlockedReward.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    Image("iconRewardGift")
                        .foregroundStyle(Color.asphyrWarning)
                        .frame(width: 40, height: 40)
                        .background(Color.asphyrWarning.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("NEW REWARD UNLOCKED")
                            .font(AppTypography.captionMedium)
                            .foregroundStyle(Color.asphyrWarning)

                        Text(isShowingUnlockedReward ? "Here’s what you earned" : "Tap to see what you earned")
                            .font(AppTypography.bodySecondary)
                            .foregroundStyle(Color.asphyrTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image("iconChevronRight")
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .rotationEffect(.degrees(isShowingUnlockedReward ? 90 : 0))
                        .accessibilityHidden(true)
                }

                if isShowingUnlockedReward {
                    Rectangle()
                        .fill(Color.asphyrBorder)
                        .frame(height: 1)
                        .padding(.top, 14)

                    ForEach(completion.newCloaks, id: \.level) { cloak in
                        Text(cloak.name)
                            .font(AppTypography.bodySemiBold)
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .padding(.top, 14)

                        Text("Unlocked at level \(cloak.level).")
                            .font(AppTypography.bodySecondary)
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .padding(.top, 2)
                    }
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.asphyrBorder, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityValue(isShowingUnlockedReward ? "Expanded" : "Collapsed")
    }
}

#Preview("Level up") {
    RewardView(
        completion: QuestCompletion(
            quest: Quest.sampleDaily,
            elapsed: 1800,
            levelBefore: 2,
            levelAfter: 3,
            xpIntoLevel: 0,
            xpForLevel: 900,
            newCloaks: [RewardRules.cloaks[0]]
        )
    )
    .environment(OnboardingProfile())
}

#Preview("No level up") {
    RewardView(
        completion: QuestCompletion(
            quest: Quest.sampleDaily,
            elapsed: 768,
            levelBefore: 1,
            levelAfter: 1,
            xpIntoLevel: 100,
            xpForLevel: 500,
            newCloaks: []
        )
    )
    .environment(OnboardingProfile())
}
