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
    /// Missing outside the tabs, such as in previews, where the link does nothing.
    @Environment(TabNavigator.self) private var navigator: TabNavigator?

    /// How far the reveal has got. Each part appears once its step is reached,
    /// so a tap can jump straight to the end.
    @State private var revealStep = 0
    @State private var barProgress: CGFloat = 0
    /// After a level up, the bar refills and the new level pops.
    @State private var isNewLevelShown = false
    @State private var cardLandings = 0
    @State private var revealTask: Task<Void, Never>?
    @State private var barTask: Task<Void, Never>?
    @State private var isShowingUnlockedReward = false
    /// Surprised as the rewards appear, then settles on how the quest went.
    @State private var spiritMood: SpiritView.Mood = .surprised

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
        GeometryReader { proxy in
            ScrollView {
                rewardContent
                    // Centered, so a short reward doesn't leave a gap above the button
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: skipReveal)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PrimaryButton(title: "CONTINUE") {
                dismiss()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(Color.asphyrBackground)
        }
        .background(Color.asphyrBackground.ignoresSafeArea())
        .hapticFeedback(.success, trigger: shows(Reveal.spirit))
        .hapticFeedback(.impact(weight: .light), trigger: cardLandings)
        .onAppear {
            revealTask = Task { await reveal() }
        }
        .onDisappear {
            revealTask?.cancel()
            barTask?.cancel()
        }
    }

    // MARK: Reveal

    private enum Reveal {
        static let spirit = 1
        static let words = 2
        static let xpCard = 3
        static let firstAttribute = 4
        static let bar = 5
        static let secondAttribute = 6
        static let embers = 7
        static let done = 8
    }

    private func shows(_ step: Int) -> Bool {
        revealStep >= step
    }

    private var finalMood: SpiritView.Mood {
        quest.isBonusReward ? .happy : .cheer
    }

    /// Where the bar starts: the XP before this quest, in the level it was earned in.
    private var barStart: CGFloat {
        let earned = quest.xpReward
        guard completion.didLevelUp else {
            return CGFloat(max(0, completion.xpIntoLevel - earned)) / CGFloat(completion.xpForLevel)
        }
        let needed = RewardRules.xpNeeded(forLevel: completion.levelBefore)
        return CGFloat(max(0, needed - max(0, earned - completion.xpIntoLevel))) / CGFloat(needed)
    }

    private var barEnd: CGFloat {
        CGFloat(completion.xpIntoLevel) / CGFloat(completion.xpForLevel)
    }

    private func reveal() async {
        barProgress = barStart
        let timeline: [(seconds: Double, step: Int)] = [
            (0, Reveal.spirit),
            (0.08, Reveal.words),
            (0.15, Reveal.xpCard),
            (0.6, Reveal.firstAttribute),
            (0.9, Reveal.bar),
            (1.05, Reveal.secondAttribute),
            (1.3, Reveal.embers)
        ]
        var elapsed = 0.0

        for moment in timeline {
            try? await Task.sleep(for: .seconds(moment.seconds - elapsed))
            elapsed = moment.seconds
            guard !Task.isCancelled else { return }

            revealStep = moment.step
            if [Reveal.xpCard, Reveal.firstAttribute, Reveal.secondAttribute].contains(moment.step) {
                cardLandings += 1
            }
            if moment.step == Reveal.bar {
                spiritMood = finalMood
                barTask = Task { await fillBar() }
            }
        }
        revealStep = Reveal.done
    }

    /// Fills from the old XP to the new. A level up fills the old level first,
    /// then starts the new one.
    private func fillBar() async {
        if completion.didLevelUp {
            withAnimation(.easeIn(duration: 0.5)) {
                barProgress = 1
            }
            try? await Task.sleep(for: .seconds(0.55))
            guard !Task.isCancelled else { return }

            barProgress = 0
            // Lets the empty bar draw before it fills again
            try? await Task.sleep(for: .milliseconds(30))
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                isNewLevelShown = true
            }
        }
        withAnimation(.easeOut(duration: 0.6)) {
            barProgress = barEnd
        }
    }

    /// A tap anywhere shows the finished screen at once.
    private func skipReveal() {
        guard revealStep < Reveal.done || barProgress != barEnd else { return }
        revealTask?.cancel()
        barTask?.cancel()

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            revealStep = Reveal.done
            barProgress = barEnd
            isNewLevelShown = completion.didLevelUp
            spiritMood = finalMood
        }
    }

    private var rewardContent: some View {
        VStack(spacing: 0) {
            spotlight

            VStack(alignment: .leading, spacing: 0) {
                lootCards
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)

                if completion.embersEarned > 0 {
                    embersEarned
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                }

                if quest.isBonusReward {
                    Text("Small progress is still progress.")
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                }

                experience
                    .padding(.top, 29)

                if !completion.newCloaks.isEmpty {
                    unlockedReward
                        .padding(.top, 20)

                    if isShowingUnlockedReward {
                        Button("VIEW IN INVENTORY") {
                            navigator?.openInventory()
                            dismiss()
                        }
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrAccentPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .padding(.top, 8)
    }

    /// A band across the full width, so the win fills the screen like the cards below.
    private var spotlight: some View {
        VStack(spacing: 0) {
            VStack(spacing: 3) {
                Text("QUEST COMPLETE")
                    .font(AppTypography.screenTitle)
                    .foregroundStyle(Color.asphyrAccentPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(quest.title)
                    .font(AppTypography.subheading)
                    .foregroundStyle(Color.asphyrTextPrimary)
            }
            .multilineTextAlignment(.center)

            spiritMessage
                .padding(.top, 10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Color.asphyrAccentPrimary.opacity(0.06))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.asphyrAccentPrimary.opacity(0.18))
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.asphyrAccentPrimary.opacity(0.18))
                .frame(height: 1)
        }
    }

    private var spiritMessage: some View {
        VStack(spacing: 2) {
            SpiritView(mood: spiritMood, size: 150)
                .scaleEffect(shows(Reveal.spirit) ? 1 : 0.6)
                .opacity(shows(Reveal.spirit) ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: shows(Reveal.spirit))

            // Pops in after the spirit, like the reward cards
            VStack(spacing: 4) {
                Text("Nice work, \(displayName)!")
                    .font(AppTypography.bodySemiBold)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(completion.didLevelUp ? "You reached level \(completion.levelAfter)." : clearedText)
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(completion.didLevelUp ? Color.asphyrAccentPrimary : Color.asphyrTextSecondary)
            }
            .multilineTextAlignment(.center)
            .scaleEffect(shows(Reveal.words) ? 1 : 0.6)
            .opacity(shows(Reveal.words) ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: shows(Reveal.words))
        }
    }

    /// The XP card sits in the middle, with up to two attributes tilted beside it.
    private var embersEarned: some View {
        HStack(spacing: 6) {
            Image("iconEmber")
            Text("+\(completion.embersEarned) Embers")
                .font(AppTypography.bodySemiBold)
        }
        .foregroundStyle(Color.asphyrWarning)
        .accessibilityElement(children: .combine)
        // Arrives after the loot cards
        .opacity(shows(Reveal.embers) ? 1 : 0)
        .animation(.easeOut(duration: 0.3), value: shows(Reveal.embers))
    }

    private var lootCards: some View {
        let attributes = Array(quest.attributeRewards.prefix(2))

        return HStack(spacing: 11) {
            if let attribute = attributes.first {
                lootCard(
                    value: attribute.value,
                    label: attribute.name,
                    iconName: attribute.iconName,
                    color: .asphyrAccentPrimary,
                    step: Reveal.firstAttribute
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
                step: Reveal.xpCard
            )

            if attributes.count > 1 {
                lootCard(
                    value: attributes[1].value,
                    label: attributes[1].name,
                    iconName: attributes[1].iconName,
                    color: .asphyrAccentPrimary,
                    step: Reveal.secondAttribute
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
        step: Int
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

            // Rolls up from zero as the card lands
            Text("+\(shows(step) ? value : 0)")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(color)
                .contentTransition(.numericText(value: Double(shows(step) ? value : 0)))
                .animation(.easeOut(duration: 0.6), value: shows(step))
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
        .scaleEffect(shows(step) ? 1 : 0.6)
        .opacity(shows(step) ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: shows(step))
    }

    private var experience: some View {
        VStack(spacing: 5) {
            HStack {
                // A level up gets its own pop once the old level fills
                Text("LEVEL \(isNewLevelShown || !completion.didLevelUp ? completion.levelAfter : completion.levelBefore)")
                    .foregroundStyle(isNewLevelShown ? Color.asphyrAccentPrimary : Color.asphyrTextSecondary)
                    .contentTransition(.numericText())
                    .scaleEffect(isNewLevelShown ? 1.25 : 1, anchor: .leading)

                Spacer()
                Text("\(completion.xpIntoLevel) / \(completion.xpForLevel) XP")
            }
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrTextSecondary)

            XPBar(progress: barProgress)
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

#Preview("Level up", traits: .dark) {
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

#Preview("No level up", traits: .dark) {
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
