//
//  MainTabView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

private enum MainTab: String, CaseIterable, Identifiable {
    case home = "HOME"
    case quests = "QUESTS"
    case journey = "JOURNEY"
    case character = "CHARACTER"

    var id: Self { self }

    var iconName: String {
        switch self {
        case .home: "iconTabHome"
        case .quests: "iconTabQuests"
        case .journey: "iconTabJourney"
        case .character: "iconTabCharacter"
        }
    }
}

extension EnvironmentValues {
    /// Switches to the Character tab, for screens that link to it.
    @Entry var openCharacter: () -> Void = {}
    /// Switches to the Quests tab.
    @Entry var openQuests: () -> Void = {}
}

struct MainTabView: View {
    @State private var selection: MainTab = .home
    @Environment(OnboardingProfile.self) private var profile
    @Environment(AppSettings.self) private var settings
    @Environment(\.scenePhase) private var scenePhase

    @State private var questStore = QuestStore(quests: [])

    var body: some View {
        TabView(selection: $selection) {
            Tab(value: MainTab.home) {
                // The bar sits inside the stack so pushed screens cover it
                NavigationStack {
                    HomeView()
                        .mainTabBar(selection: $selection)
                }
            }

            Tab(value: MainTab.quests) {
                NavigationStack {
                    QuestView()
                        .mainTabBar(selection: $selection)
                }
            }

            Tab(value: MainTab.journey) {
                JourneyView()
                    .mainTabBar(selection: $selection)
            }

            Tab(value: MainTab.character) {
                CharacterView()
                    .mainTabBar(selection: $selection)
            }
        }
        .environment(questStore)
        .environment(\.openCharacter) { selection = .character }
        .environment(\.openQuests) { selection = .quests }
        .onAppear(perform: refreshDailyQuest)
        .onAppear(perform: updateStreakAlert)
        .onChange(of: questStore.completionDates) { updateStreakAlert() }
        .onChange(of: settings.pushNotifications) { updateStreakAlert() }
        .onChange(of: settings.streakAlerts) { updateStreakAlert() }
        .onChange(of: settings.showsStreaks) { updateStreakAlert() }
        // A new day can start while the app is in the background
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                refreshDailyQuest()
                updateStreakAlert()
            }
        }
    }

    private func updateStreakAlert() {
        ReminderNotifications.updateStreakAlert(from: settings, completions: questStore.completionDates)
    }

    private func refreshDailyQuest() {
        questStore.refreshDailyQuest(aspiration: profile.aspiration, archetype: profile.archetype)
    }
}

/// Figma's floating bar, which iOS's own tab bar can't match. `TabView` still
/// keeps each tab's state.
private struct MainTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(tab.iconName)
                        Text(tab.rawValue)
                            .font(AppTypography.captionRegular)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selection == tab ? Color.asphyrAccentPrimary : Color.asphyrTextSecondary)
                    // Swaps instantly, as animating this color flashed purple on the icons
                    .id(selection == tab)
                    .transition(.identity)
                    .transaction { $0.animation = nil }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 64)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.asphyrSurface)
                .shadow(color: .black.opacity(0.5), radius: 7.5, x: 0, y: 10)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }
}

private extension View {
    func mainTabBar(selection: Binding<MainTab>) -> some View {
        toolbar(.hidden, for: .tabBar)
            // Lets scrolling content end above the floating bar
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 64)
            }
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: Color.asphyrBackground.opacity(0.95), location: 0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 130)
                    .allowsHitTesting(false)

                    MainTabBar(selection: selection)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 22)
                }
                .ignoresSafeArea(edges: .bottom)
            }
    }
}

#Preview {
    MainTabView()
        .environment(OnboardingProfile())
        .environment(AppSettings())
}
