//
//  MainTabView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
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

/// Lets screens inside the tabs switch tabs. An object rather than closures in
/// the environment, which SwiftUI can't compare and would treat as always changed.
@Observable
final class TabNavigator {
    var selection: MainTab = .home
    /// Bumped to make Home open the Inventory.
    private(set) var inventoryRequest = 0
    /// Shown over the tabs, so closing it reveals the screen the quest was opened
    /// from rather than Quest Details.
    var rewardCompletion: QuestCompletion?

    func openQuests() {
        selection = .quests
    }

    func openInventory() {
        selection = .home
        inventoryRequest += 1
    }
}

struct MainTabView: View {
    @State private var navigator = TabNavigator()
    @Environment(OnboardingProfile.self) private var profile
    @Environment(AppSettings.self) private var settings
    @Environment(\.scenePhase) private var scenePhase
    @Environment(QuestStore.self) private var questStore

    /// Read from the phone once, so the bar sits the same way on every iPhone.
    @State private var tabBarMetrics = TabBarMetrics(deviceBottomInset: 34)

    var body: some View {
        TabView(selection: $navigator.selection) {
            Tab(value: MainTab.home) {
                // The bar sits inside the stack so pushed screens cover it
                NavigationStack {
                    HomeView(inventoryRequest: navigator.inventoryRequest)
                        .mainTabBar(selection: $navigator.selection, metrics: tabBarMetrics)
                }
            }

            Tab(value: MainTab.quests) {
                NavigationStack {
                    QuestsView()
                        .mainTabBar(selection: $navigator.selection, metrics: tabBarMetrics)
                }
            }

            Tab(value: MainTab.journey) {
                JourneyView()
                    .mainTabBar(selection: $navigator.selection, metrics: tabBarMetrics)
            }

            Tab(value: MainTab.character) {
                CharacterView()
                    .mainTabBar(selection: $navigator.selection, metrics: tabBarMetrics)
            }
        }
        .fullScreenCover(item: $navigator.rewardCompletion) { completion in
            RewardView(completion: completion)
        }
        .environment(navigator)
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

    @Environment(\.colorScheme) private var colorScheme

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
                // A dark shadow reads as a smudge on Light's pale background
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.5 : 0.1), radius: 7.5, x: 0, y: 10)
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
    /// How far the backdrop fades in above the solid part.
    static let fadeHeight: CGFloat = 14

    /// The home indicator's area: 34pt on Face ID iPhones, 0 on an iPhone SE.
    let deviceBottomInset: CGFloat

    /// From the screen's bottom edge: just above the home indicator, or a small margin.
    var barBottom: CGFloat { deviceBottomInset > 0 ? 12 : 10 }

    var barTop: CGFloat { barBottom + Self.barHeight }

    /// The room content leaves above the safe area, so it ends just above the bar.
    var contentInset: CGFloat { max(0, barTop - deviceBottomInset) + Self.contentGap }

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
    /// The bar sits in a bottom safe-area inset, so content scrolls to just above
    /// it on every iPhone and iOS version. The backdrop is solid from just above
    /// the bar to the screen's edge, so nothing shows or can be tapped under it.
    func mainTabBar(selection: Binding<MainTab>, metrics: TabBarMetrics) -> some View {
        toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MainTabBar(selection: selection)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: metrics.contentInset, alignment: .bottom)
                    // Lowers the bar into the home indicator's area, measured from the screen's edge
                    .offset(y: metrics.deviceBottomInset - metrics.barBottom)
                    .background(alignment: .top) {
                        LinearGradient(
                            stops: [
                                .init(color: Color.asphyrBackground.opacity(0), location: 0),
                                .init(color: Color.asphyrBackground, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: TabBarMetrics.fadeHeight)
                        .offset(y: -TabBarMetrics.fadeHeight)
                        .allowsHitTesting(false)
                    }
                    .background {
                        Color.asphyrBackground
                            .ignoresSafeArea(edges: .bottom)
                    }
            }
            // The keyboard covers the bar and the create button, as in other apps,
            // rather than pushing them up the screen
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview(traits: .dark) {
    MainTabView()
        .environment(OnboardingProfile())
        .environment(AppSettings())
        .environment(QuestStore())
}
