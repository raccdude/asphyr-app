//
//  CloakGrid.swift
//  Asphyr
//

import SwiftUI

/// Every cloak, to choose what the character wears. Locked ones shake and say how to
/// get them: a level for level cloaks, Embers for store cloaks. Shown in Inventory.
struct CloakGrid: View {
    /// Says how to get a locked cloak, in the screen's own toast.
    let onLockedTap: (String) -> Void

    @Environment(OnboardingProfile.self) private var profile
    @Environment(QuestStore.self) private var questStore

    @State private var cloakShakes: [CharacterCloak: Int] = [:]
    @State private var lockedTapCount = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
            cloakOption(
                title: "Starter",
                detail: "",
                swatch: CloakPalette.starter.top,
                isSelected: profile.cloak == nil,
                isLocked: false
            ) {
                profile.cloak = nil
            }

            ForEach(CharacterCloak.allCases) { cloak in
                let isLocked = !questStore.owns(cloak.rawValue)
                let level = cloak.reward?.level
                let price = questStore.price(of: cloak.rawValue)

                cloakOption(
                    title: cloak.rawValue,
                    detail: lockedDetail(level: level, price: price),
                    swatch: cloak.palette.top,
                    isSelected: profile.cloak == cloak,
                    isLocked: isLocked
                ) {
                    if isLocked {
                        withAnimation(.linear(duration: 0.4)) {
                            cloakShakes[cloak, default: 0] += 1
                        }
                        lockedTapCount += 1
                        onLockedTap(howToGet(level: level, price: price))
                    } else {
                        profile.cloak = cloak
                    }
                }
                .modifier(ShakeEffect(shakes: CGFloat(cloakShakes[cloak, default: 0])))
            }
        }
        .hapticFeedback(.warning, trigger: lockedTapCount)
    }

    private func lockedDetail(level: Int?, price: Int?) -> String {
        if let level { return "Level \(level)" }
        if let price { return "\(price) Embers" }
        return "Coming soon"
    }

    private func howToGet(level: Int?, price: Int?) -> String {
        if let level { return "Reach level \(level) to unlock this cloak." }
        if let price { return "Get it for \(price) Embers in the Store." }
        return "This cloak is coming soon to the store."
    }

    private func cloakOption(
        title: String,
        detail: String,
        swatch: Color,
        isSelected: Bool,
        isLocked: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ColorSwatch(color: swatch, isSelected: isSelected)
                    .frame(width: 44, height: 44)
                    .overlay {
                        if isLocked {
                            Image("iconBadgeLock")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(Color.asphyrTextPrimary)
                        }
                    }

                VStack(spacing: 2) {
                    Text(title)
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(isLocked ? Color.asphyrTextSecondary : Color.asphyrTextPrimary)

                    if isLocked {
                        Text(detail)
                            .font(AppTypography.captionRegular)
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLocked ? "\(title) cloak, locked, \(detail)" : title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview(traits: .dark) {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        CloakGrid { _ in }
            .padding(.horizontal, 20)
    }
    .environment(OnboardingProfile())
    .environment(QuestStore())
}
