//
//  CharacterView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct CharacterView: View {
    @Environment(OnboardingProfile.self) private var profile
    @Environment(QuestStore.self) private var questStore

    @State private var mood: CharacterPortrait.Mood = .idle
    @State private var toast: String?
    @State private var toastCount = 0

    private let badgeColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

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
                    header

                    CharacterButton(
                        color: profile.color,
                        archetype: profile.archetype,
                        cloak: profile.cloak,
                        mood: $mood,
                        size: 184
                    )
                    .padding(.top, 8)

                    identity
                        .padding(.top, 28)

                    experienceCard
                        .padding(.top, 24)

                    SectionDivider(sectionTitle: "CUSTOMIZE")
                        .padding(.top, 32)

                    colorPicker
                        .padding(.top, 14)

                    SectionDivider(sectionTitle: "ATTRIBUTES")
                        .padding(.top, 32)

                    attributesCard
                        .padding(.top, 20)

                    SectionDivider(sectionTitle: "ACHIEVEMENTS")
                        .padding(.top, 32)

                    if questStore.earnedAchievements.isEmpty {
                        Text("Complete your first quest to earn your first badge.")
                            .font(AppTypography.bodySecondary)
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                    }

                    LazyVGrid(columns: badgeColumns, spacing: 10) {
                        ForEach(Achievement.allCases, id: \.self, content: badge)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .overlay(alignment: .top) {
            if let toast {
                AsphyrToast(icon: "iconAlert", message: toast)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toast)
        // Happy for a moment after finishing a quest
        .onChange(of: questStore.completionDates.count) { oldCount, newCount in
            guard newCount > oldCount else { return }
            mood = .happy

            Task {
                try? await Task.sleep(for: .seconds(4))
                if mood == .happy {
                    mood = .idle
                }
            }
        }
        .task(id: toastCount) {
            guard toast != nil else { return }

            do {
                try await Task.sleep(for: .seconds(3))
                toast = nil
            } catch {
                // A newer tap restarted the delay
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("IDENTITY")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)

            Text("CHARACTER")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // Lines up with the header on Home and Journey
        .padding(.top, 14)
    }

    private var identity: some View {
        VStack(spacing: 0) {
            Text(displayName)
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)

            if let archetype = profile.archetype {
                Text("THE \(archetype.title.uppercased())")
                    .font(AppTypography.subheading)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .padding(.top, 8)
            }

            if let aspiration = profile.aspiration {
                Text(aspiration)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .padding(.top, 5)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var experienceCard: some View {
        HStack(spacing: 16) {
            Text("\(questStore.level)")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrAccentPrimary)
                .frame(width: 58, height: 58)
                .overlay {
                    Circle()
                        .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 2)
                }
                .shadow(color: Color.asphyrAccentPrimary.opacity(0.25), radius: 8)
                .accessibilityLabel("Level \(questStore.level)")

            VStack(spacing: 8) {
                HStack {
                    Text("EXPERIENCE")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextPrimary)

                    Spacer(minLength: 8)

                    Text("\(questStore.xpIntoLevel) / \(questStore.xpForLevel) XP")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrWarning)
                }

                XPBar(
                    progress: CGFloat(questStore.xpIntoLevel) / CGFloat(questStore.xpForLevel),
                    height: 6
                )
            }
        }
        .padding(18)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private var colorPicker: some View {
        HStack(spacing: 0) {
            ForEach(CharacterColor.allCases) { color in
                Button {
                    profile.color = color
                } label: {
                    ColorSwatch(color: color.swatch, isSelected: profile.color == color)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(color.rawValue)
                .accessibilityAddTraits(profile.color == color ? .isSelected : [])
            }
        }
    }

    private var attributesCard: some View {
        VStack(spacing: 24) {
            ForEach(UserAttribute.iconNames, id: \.name) { attribute in
                let value = questStore.attributeValue(named: attribute.name)

                HStack(spacing: 14) {
                    Image(attribute.iconName)
                        .foregroundStyle(Color.asphyrAccentPrimary)
                        .frame(width: 32, height: 32)
                        .background(Color.asphyrAccentPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                        .accessibilityHidden(true)

                    Text(attribute.name)
                        .font(AppTypography.captionRegular)
                        .foregroundStyle(Color.asphyrTextPrimary)
                        .frame(width: 92, alignment: .leading)

                    XPBar(progress: UserAttribute.barProgress(forValue: value), height: 6, motion: .fillsOnAppear)
                        .accessibilityHidden(true)

                    Text("\(value)")
                        .font(AppTypography.subheading)
                        .foregroundStyle(Color.asphyrTextPrimary)
                        .frame(minWidth: 26, alignment: .trailing)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(16)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private func badge(_ achievement: Achievement) -> some View {
        let isEarned = questStore.earnedAchievements.contains(achievement)

        return Button {
            showToast(isEarned ? "\(achievement.title) earned." : achievement.requirement)
        } label: {
            VStack(spacing: 10) {
                Group {
                    if isEarned {
                        Image(achievement.iconName)
                            .foregroundStyle(Color.asphyrAccentPrimary)
                            .frame(width: 50, height: 50)
                            .background(Color.asphyrAccentPrimary.opacity(0.12), in: Circle())
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 1)
                            }
                    } else {
                        Image("iconBadgeLock")
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .frame(width: 50, height: 50)
                            .background(Color.asphyrSurfaceElevated, in: Circle())
                    }
                }
                .accessibilityHidden(true)

                Text(achievement.title)
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(isEarned ? Color.asphyrTextPrimary : Color.asphyrTextSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 105)
            .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.asphyrBorder, lineWidth: 1)
            }
            .opacity(isEarned ? 1 : 0.7)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityValue(isEarned ? "Earned" : "Locked")
        .accessibilityHint(achievement.requirement)
    }

    private func showToast(_ message: String) {
        toast = message
        toastCount += 1
    }
}

#Preview("New user", traits: .dark) {
    let profile = OnboardingProfile()
    profile.name = "Lou"
    profile.archetype = .strategist
    profile.aspiration = "Game Developer"

    return CharacterView()
        .environment(profile)
        .environment(QuestStore())
}
