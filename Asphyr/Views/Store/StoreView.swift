//
//  StoreView.swift
//  Asphyr
//

import SwiftUI

/// The Store, where Embers buy cloaks, and the Inventory, where owned cloaks are worn.
/// Pushed from Home's Ember chip, or from Reward's "View in Inventory".
struct StoreView: View {
    enum Tab: String, CaseIterable {
        case store = "STORE"
        case inventory = "INVENTORY"
    }

    @Environment(QuestStore.self) private var questStore

    @State private var tab: Tab
    @State private var pendingPurchase: StoreItemRecord?
    @State private var isBuying = false
    @State private var toast: String?
    @Namespace private var tabNamespace

    private let storeColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    init(initialTab: Tab = .store) {
        _tab = State(initialValue: initialTab)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                tabBar
                    .padding(.top, 8)

                switch tab {
                case .store:
                    storeContent
                        .padding(.top, 20)
                case .inventory:
                    inventoryContent
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.asphyrBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            SettingsNavigationTitle(title: tab == .store ? "STORE" : "INVENTORY")

            ToolbarItem(placement: .topBarTrailing) {
                EmberBalance(embers: questStore.embers)
            }
        }
        .alert(
            "Buy this cloak?",
            isPresented: Binding(
                get: { pendingPurchase != nil },
                set: { if !$0 { pendingPurchase = nil } }
            ),
            presenting: pendingPurchase
        ) { item in
            Button("Buy") { buy(item) }
            Button("Cancel", role: .cancel) {}
        } message: { item in
            Text("Buy the \(item.item) cloak for \(item.price) Embers?")
        }
        .settingsToast($toast, icon: "iconEmber")
    }

    private var tabBar: some View {
        HStack(spacing: 2) {
            ForEach(Tab.allCases, id: \.self) { option in
                let isSelected = tab == option

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                        tab = option
                    }
                } label: {
                    Text(option.rawValue)
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(isSelected ? Color.asphyrTextPrimary : Color.asphyrTextSecondary)
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color.asphyrSurfaceElevated)
                                    .shadow(color: .black.opacity(0.4), radius: 0.5, x: 0, y: 1)
                                    .matchedGeometryEffect(id: "selectedTab", in: tabNamespace)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(5)
        .frame(minHeight: 44)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 13))
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private var storeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Earn Embers by completing quests: 1 for every 10 XP.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)

            if questStore.storeItems.isEmpty {
                Text("The store is closed right now. Check your connection and try again.")
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .padding(.top, 20)
            } else {
                LazyVGrid(columns: storeColumns, spacing: 12) {
                    ForEach(questStore.storeItems, id: \.item) { item in
                        if let cloak = CharacterCloak(rawValue: item.item) {
                            StoreCloakCard(cloak: cloak, price: item.price) {
                                tapBuy(item)
                            }
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
    }

    private var inventoryContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionDivider(sectionTitle: "CLOAKS")

            CloakGrid { message in
                toast = message
            }
            .padding(.top, 14)

            Text("Level cloaks unlock as you level up. Store cloaks are bought with Embers.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 20)
        }
    }

    private func tapBuy(_ item: StoreItemRecord) {
        let shortfall = item.price - questStore.embers
        if shortfall > 0 {
            toast = "You need \(shortfall) more Embers. Complete quests to earn them."
        } else {
            pendingPurchase = item
        }
    }

    private func buy(_ item: StoreItemRecord) {
        guard !isBuying else { return }

        isBuying = true
        Task {
            defer { isBuying = false }

            do {
                try await questStore.buyCloak(item.item)
                toast = "The \(item.item) cloak is yours. Tap Wear to put it on."
            } catch {
                if let message = (error as? QuestError)?.message {
                    toast = message
                }
            }
        }
    }
}

/// The Ember balance, as on Home's chip.
struct EmberBalance: View {
    let embers: Int

    var body: some View {
        HStack(spacing: 6) {
            Image("iconEmber")
            Text("\(embers)")
                .font(AppTypography.subheading)
                .monospacedDigit()
        }
        .foregroundStyle(Color.asphyrWarning)
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(Color.asphyrWarning.opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.asphyrWarning.opacity(0.4), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(embers) Embers")
    }
}

#Preview(traits: .dark) {
    NavigationStack {
        StoreView()
    }
    .environment(OnboardingProfile())
    .environment(QuestStore())
}
