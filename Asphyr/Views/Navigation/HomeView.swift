//
//  HomeView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct HomeView: View {
    private var attributes: [UserAttribute] {
        UserAttribute.iconNames.map { attribute in
            UserAttribute(
                name: attribute.name,
                value: "\(questStore.attributeValue(named: attribute.name))",
                iconName: attribute.iconName
            )
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @Environment(OnboardingProfile.self) private var profile
    @Environment(QuestStore.self) private var questStore
    @Environment(AppSettings.self) private var settings

    @State private var isShowingSettings = false
    @State private var isShowingStreak = false
    @State private var selectedQuestID: UUID?
    @State private var isShowingCreateQuest = false
    @State private var characterMood: CharacterPortrait.Mood = .idle

    private var streak: StreakStatus {
        StreakRules.status(completions: questStore.completionDates)
    }

    /// The character sleeps along with the flame, unless streaks are hidden.
    private var isResting: Bool {
        settings.showsStreaks && streak.state == .resting
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "GOOD MORNING"
        case 12..<18: "GOOD AFTERNOON"
        default: "GOOD EVENING"
        }
    }

    /// Login skips onboarding until real accounts exist, so the name can be empty.
    private var displayName: String {
        profile.name.isEmpty ? "Traveler" : profile.name
    }

    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(AppTypography.bodySecondary)
                            .foregroundStyle(Color.asphyrTextPrimary)

                        Text(displayName)
                            .font(AppTypography.screenTitle)
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 26)

                    CharacterButton(
                        color: profile.color,
                        archetype: profile.archetype,
                        cloak: profile.cloak,
                        mood: $characterMood,
                        restingMood: isResting ? .sleepy : .idle
                    )
                    .padding(.top, -6)

                    identity
                        .padding(.top, 18)

                    Text("LEVEL \(questStore.level)")
                        .font(AppTypography.subheading)
                        .foregroundStyle(Color(red: 3 / 255, green: 20 / 255, blue: 10 / 255))
                        .padding(.horizontal, 14)
                        .frame(height: 29)
                        .background(Color.asphyrAccentPrimary, in: Capsule())
                        .padding(.top, 10)

                    xpProgress
                        .padding(.top, 22)

                    if let quest = questStore.homeQuest {
                        SectionDivider(sectionTitle: questSectionTitle(for: quest))
                            .padding(.top, 30)

                        Button {
                            selectedQuestID = quest.id
                        } label: {
                            QuestCard(quest: questStore.withCurrentRewards(quest))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 14)
                    } else if !questStore.completedQuests.isEmpty {
                        SectionDivider(sectionTitle: "TODAY’S PROGRESS")
                            .padding(.top, 30)

                        QuestCompletionCard(
                            questCount: questStore.completedQuests.count,
                            xp: questStore.completedQuests.reduce(0) { $0 + $1.xpReward }
                        ) {
                            isShowingCreateQuest = true
                        }
                        .padding(.top, 14)
                    }

                    SectionDivider(sectionTitle: "ATTRIBUTES")
                        .padding(.top, 30)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(attributes, id: \.name) { attribute in
                            AttributeCard(attribute: attribute)
                        }
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingStreak) {
            StreakSheet(status: streak)
        }
        .onAppear {
            if isResting {
                characterMood = .sleepy
            }
        }
        .onChange(of: isResting) {
            if isResting {
                characterMood = .sleepy
            } else if characterMood == .sleepy {
                characterMood = .idle
            }
        }
        // Happy for a moment after finishing a quest
        .onChange(of: questStore.completionDates.count) { oldCount, newCount in
            guard newCount > oldCount else { return }
            characterMood = .happy

            Task {
                try? await Task.sleep(for: .seconds(4))
                if characterMood == .happy {
                    characterMood = isResting ? .sleepy : .idle
                }
            }
        }
        .navigationDestination(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .navigationDestination(item: $selectedQuestID) { questID in
            QuestDetailsView(questID: questID)
        }
        .sheet(isPresented: $isShowingCreateQuest) {
            CreateQuestView()
        }
    }

    private func questSectionTitle(for quest: Quest) -> String {
        if quest.status == .active { return "ACTIVE QUEST" }
        return quest.type == .dailyQuest ? "TODAY’S QUEST" : "AVAILABLE QUEST"
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("ASPHYR")
                .font(AppTypography.wordMark)
                .tracking(1.44)
                .foregroundStyle(Color.asphyrAccentPrimary)
                .lineLimit(1)

            Spacer(minLength: 0)

            if settings.showsStreaks, streak.state != .none {
                Button {
                    isShowingStreak = true
                } label: {
                    if streak.state == .resting {
                        restingChip
                    } else {
                        streakChip
                    }
                }
                .buttonStyle(.plain)
            }

            Button {
                isShowingSettings = true
            } label: {
                Image("iconGear")
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .glassEffect(.regular.interactive(), in: Circle())
            // Dark glass until the app's light colors exist
            .environment(\.colorScheme, .dark)
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 20)
        // Lines up with the wordmark on auth screens
        .padding(.top, 14)
        // Solid, so content scrolling up doesn't show behind the wordmark
        .background(Color.asphyrBackground.ignoresSafeArea(edges: .top))
    }

    private var streakChip: some View {
        HStack(spacing: 6) {
            Image("iconFlame")
            Text("\(streak.days)")
                .font(AppTypography.subheading)
        }
        .foregroundStyle(Color.asphyrAccentPrimary)
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(Color.asphyrAccentPrimary.opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.asphyrAccentPrimary.opacity(0.4), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(streak.days)-day streak")
    }

    private var restingChip: some View {
        HStack(spacing: 6) {
            Image("iconFlame")
            Text("Rest")
                .font(AppTypography.bodySecondary)
        }
        .foregroundStyle(Color.asphyrTextSecondary)
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(Color.asphyrSurface, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Your flame is resting")
    }

    @ViewBuilder
    private var identity: some View {
        VStack(spacing: 4) {
            if let archetype = profile.archetype {
                Text("THE \(archetype.title.uppercased())")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(Color.asphyrTextPrimary)
            }

            if let aspiration = profile.aspiration {
                Text(aspiration)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.asphyrTextPrimary)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var xpProgress: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(questStore.xpIntoLevel) / \(questStore.xpForLevel) XP")
                    .foregroundStyle(Color.asphyrTextPrimary)

                Spacer()

                Text("\(questStore.xpForLevel - questStore.xpIntoLevel) XP TO LEVEL \(questStore.level + 1)")
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .font(AppTypography.captionMedium)

            XPBar(progress: CGFloat(questStore.xpIntoLevel) / CGFloat(questStore.xpForLevel))
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(OnboardingProfile())
    .environment(QuestStore())
    .environment(AppSettings())
}

/// A store with a quest finished on each of these days ago.
private func storeWithQuests(finishedDaysAgo days: [Double]) -> QuestStore {
    QuestStore(quests: days.map { daysAgo in
        var quest = Quest.sampleDaily
        quest.status = .completed
        quest.completedAt = .now.addingTimeInterval(-daysAgo * 86_400)
        return quest
    })
}

#Preview("Streak active") {
    NavigationStack {
        HomeView()
    }
    .environment(OnboardingProfile())
    .environment(storeWithQuests(finishedDaysAgo: [1, 2, 3]))
    .environment(AppSettings())
}

#Preview("Streak resting") {
    NavigationStack {
        HomeView()
    }
    .environment(OnboardingProfile())
    .environment(storeWithQuests(finishedDaysAgo: [2, 3]))
    .environment(AppSettings())
}
