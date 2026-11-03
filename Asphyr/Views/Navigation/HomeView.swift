//
//  HomeView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct HomeView: View {
    private static let attributes = [
        UserAttribute(name: "KNOWLEDGE", value: "10", iconName: "iconAttributeKnowledge"),
        UserAttribute(name: "DISCIPLINE", value: "10", iconName: "iconAttributeDiscipline"),
        UserAttribute(name: "CREATIVITY", value: "10", iconName: "iconAttributeCreativity"),
        UserAttribute(name: "PROBLEM SOLVING", value: "10", iconName: "iconAttributeProblemSolving")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    /// Nothing counts streaks yet. The chip stays hidden at 0.
    private let streakDays = 0

    @Environment(OnboardingProfile.self) private var profile
    @Environment(QuestStore.self) private var questStore

    @State private var isShowingSettings = false

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

                    Image(profile.color.noviceImageName(holdingItemOf: profile.archetype))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 126, height: 126)
                        .accessibilityHidden(true)
                        .padding(.top, -6)

                    identity
                        .padding(.top, 18)

                    Text("LEVEL 1")
                        .font(AppTypography.subheading)
                        .foregroundStyle(Color(red: 3 / 255, green: 20 / 255, blue: 10 / 255))
                        .padding(.horizontal, 14)
                        .frame(height: 29)
                        .background(Color.asphyrAccentPrimary, in: Capsule())
                        .padding(.top, 10)

                    xpProgress
                        .padding(.top, 22)

                    if let quest = questStore.todaysQuest {
                        SectionDivider(sectionTitle: "TODAY’S QUEST")
                            .padding(.top, 30)

                        QuestCard(quest: quest)
                            .padding(.top, 14)
                    }

                    SectionDivider(sectionTitle: "ATTRIBUTES")
                        .padding(.top, 30)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Self.attributes, id: \.name) { attribute in
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
        .navigationDestination(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("ASPHYR")
                .font(AppTypography.wordMark)
                .tracking(1.44)
                .foregroundStyle(Color.asphyrAccentPrimary)
                .lineLimit(1)

            Spacer(minLength: 0)

            if streakDays > 0 {
                streakChip
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
            Text("\(streakDays)")
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
        .accessibilityLabel("\(streakDays)-day streak")
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
                Text("0 / 500 XP")
                    .foregroundStyle(Color.asphyrTextPrimary)

                Spacer()

                Text("500 XP TO LEVEL 2")
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .font(AppTypography.captionMedium)

            XPBar()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(OnboardingProfile())
    .environment(QuestStore())
}
