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
    /// Opens the Inventory, from Home.
    @Entry var openInventory: () -> Void = {}
}

struct MainTabView: View {
    @State private var selection: MainTab = .home
    @Environment(OnboardingProfile.self) private var profile
    @Environment(AppSettings.self) private var settings
    @Environment(\.scenePhase) private var scenePhase
    @Environment(QuestStore.self) private var questStore

    @State private var inventoryRequest = 0
    /// Read from the phone once, so the bar sits the same way on every iPhone.
    @State private var tabBarMetrics = TabBarMetrics(deviceBottomInset: 34)

    var body: some View {
        TabView(selection: $selection) {
            Tab(value: MainTab.home) {
                // The bar sits inside the stack so pushed screens cover it
                NavigationStack {
                    HomeView(inventoryRequest: inventoryRequest)
                        .mainTabBar(selection: $selection, metrics: tabBarMetrics)
                }
            }

            Tab(value: MainTab.quests) {
                NavigationStack {
                    QuestsView()
                        .mainTabBar(selection: $selection, metrics: tabBarMetrics)
                }
            }

            Tab(value: MainTab.journey) {
                JourneyView()
                    .mainTabBar(selection: $selection, metrics: tabBarMetrics)
            }

            Tab(value: MainTab.character) {
                CharacterView()
                    .mainTabBar(selection: $selection, metrics: tabBarMetrics)
            }
        }
        .environment(\.openCharacter) { selection = .character }
        .environment(\.openQuests) { selection = .quests }
        .environment(\.openInventory) {
            selection = .home
            inventoryRequest += 1
        }
        .onAppear {
            tabBarMetrics = TabBarMetrics(deviceBottomInset: TabBarMetrics.windowBottomInset())
        }
        .onAppear(perform: refreshDailyQuest)
        .onAppear(perform: updateStreakAlert)
        .onChange(of: questStore.completionDates) { updateStreakAlert() }
        .onChange(of: questStore.unlockedCloaks) { removeWornCloakIfLost() }
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

    /// Back to the starter look if the XP behind a worn cloak was removed.
    private func removeWornCloakIfLost() {
        guard let reward = profile.cloak?.reward, !questStore.unlockedCloaks.contains(reward) else { return }
        profile.cloak = nil
    }

    private func updateStreakAlert() {
        ReminderNotifications.updateStreakAlert(from: settings, completions: questStore.completionDates)
    }

    /// A failure is ignored, as it's asked again each time the app comes back.
    private func refreshDailyQuest() {
        Task {
            try? await questStore.refreshDailyQuestOnServer(
                aspiration: profile.aspiration,
                archetype: profile.archetype
            )
        }
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
        .frame(height: TabBarMetrics.barHeight)
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

/// Where the floating bar sits, worked out from the phone's own bottom safe area, so it
/// looks the same on an iPhone SE, a 12 Pro Max or an 18 Pro.
struct TabBarMetrics: Equatable {
    static let barHeight: CGFloat = 64
    /// Clear space between the end of the content and the top of the bar.
    static let contentGap: CGFloat = 12
    /// How far the backdrop fades in above the bar.
    static let fadeHeight: CGFloat = 14

    /// The home indicator's area: 34pt on Face ID iPhones, 0 on an iPhone SE.
    let deviceBottomInset: CGFloat

    /// From the screen's bottom edge: just above the home indicator, or a small margin.
    var barBottom: CGFloat { deviceBottomInset > 0 ? 12 : 10 }

    var barTop: CGFloat { barBottom + Self.barHeight }

    /// The room content leaves above the safe area, so it ends just above the bar.
    var contentInset: CGFloat { max(0, barTop - deviceBottomInset) + Self.contentGap }

    var backdropHeight: CGFloat { barTop + Self.fadeHeight }

    /// The key window's bottom safe area. Read once, so the keyboard doesn't move the bar.
    static func windowBottomInset() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.bottom ?? 34
    }
}

private extension View {
    func mainTabBar(selection: Binding<MainTab>, metrics: TabBarMetrics) -> some View {
        toolbar(.hidden, for: .tabBar)
            // Lets scrolling content end just above the floating bar
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: metrics.contentInset)
            }
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    // Solid behind and below the bar, so nothing shows through or under
                    // it, with a short fade above. Content above the bar isn't covered.
                    LinearGradient(
                        stops: [
                            .init(color: Color.asphyrBackground.opacity(0), location: 0),
                            .init(color: Color.asphyrBackground, location: TabBarMetrics.fadeHeight / metrics.backdropHeight),
                            .init(color: Color.asphyrBackground, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: metrics.backdropHeight)
                    .allowsHitTesting(false)

                    MainTabBar(selection: selection)
                        .padding(.horizontal, 16)
                        .padding(.bottom, metrics.barBottom)
                }
                // Measured from the screen's edge, and the keyboard never pushes it up
                .ignoresSafeArea(edges: .bottom)
            }
    }
}

#Preview(traits: .dark) {
    MainTabView()
        .environment(OnboardingProfile())
        .environment(AppSettings())
        .environment(QuestStore())
}
