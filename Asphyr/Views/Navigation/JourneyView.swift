//
//  JourneyView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct JourneyView: View {
    /// Figma's positions. They're fixed so the constellation keeps its shape,
    /// measured from the top of the 402pt frame, minus the header's height.
    private enum Layout {
        static let width: CGFloat = 402
        static let topOffset: CGFloat = 140
        static let height: CGFloat = 595

        static let stars: [CGPoint] = [
            CGPoint(x: 110, y: 700), CGPoint(x: 230, y: 640), CGPoint(x: 150, y: 540), CGPoint(x: 290, y: 470),
            CGPoint(x: 90, y: 410), CGPoint(x: 210, y: 350), CGPoint(x: 201, y: 230)
        ]

        /// Pairs of star indexes joined by a line.
        static let lines = [(0, 1), (1, 2), (2, 3), (2, 4), (3, 5), (4, 5), (5, 6)]

        static let backgroundDots: [CGPoint] = [
            CGPoint(x: 30, y: 180), CGPoint(x: 90, y: 250), CGPoint(x: 360, y: 210), CGPoint(x: 330, y: 330),
            CGPoint(x: 60, y: 470), CGPoint(x: 372, y: 520), CGPoint(x: 140, y: 600), CGPoint(x: 300, y: 640),
            CGPoint(x: 50, y: 700), CGPoint(x: 250, y: 180), CGPoint(x: 180, y: 420), CGPoint(x: 370, y: 420),
            CGPoint(x: 20, y: 330), CGPoint(x: 230, y: 720), CGPoint(x: 120, y: 140)
        ]

        static func point(_ point: CGPoint) -> CGPoint {
            CGPoint(x: point.x, y: point.y - topOffset)
        }
    }

    /// Where the spirit and its speech bubble sit beside each star.
    private struct SpiritPlacement {
        let spirit: CGPoint
        let bubbleX: CGFloat
        /// The bubble's top edge, or its bottom edge when `isAbove`.
        let bubbleEdgeY: CGFloat
        let isAbove: Bool
        let bubbleWidth: CGFloat
        let pointyCorner: UnitPoint

        static let all = [
            SpiritPlacement(spirit: CGPoint(x: 56, y: 672), bubbleX: 8, bubbleEdgeY: 640, isAbove: true, bubbleWidth: 112, pointyCorner: .bottomLeading),
            SpiritPlacement(spirit: CGPoint(x: 290, y: 636), bubbleX: 272, bubbleEdgeY: 604, isAbove: true, bubbleWidth: 118, pointyCorner: .bottomTrailing),
            SpiritPlacement(spirit: CGPoint(x: 90, y: 536), bubbleX: 8, bubbleEdgeY: 572, isAbove: false, bubbleWidth: 112, pointyCorner: .topTrailing),
            SpiritPlacement(spirit: CGPoint(x: 344, y: 470), bubbleX: 272, bubbleEdgeY: 436, isAbove: true, bubbleWidth: 118, pointyCorner: .bottomTrailing),
            SpiritPlacement(spirit: CGPoint(x: 36, y: 396), bubbleX: 8, bubbleEdgeY: 364, isAbove: true, bubbleWidth: 112, pointyCorner: .bottomLeading),
            SpiritPlacement(spirit: CGPoint(x: 270, y: 346), bubbleX: 272, bubbleEdgeY: 314, isAbove: true, bubbleWidth: 118, pointyCorner: .bottomLeading),
            SpiritPlacement(spirit: CGPoint(x: 270, y: 222), bubbleX: 272, bubbleEdgeY: 256, isAbove: false, bubbleWidth: 118, pointyCorner: .topLeading)
        ]
    }

    @Environment(QuestStore.self) private var questStore
    @Environment(OnboardingProfile.self) private var profile

    private var progress: JourneyProgress {
        JourneyProgress(
            stars: JourneyProgress.stars(aspiration: profile.aspiration),
            completedQuests: questStore.completedQuests.count,
            litStarsAlreadySeen: questStore.seenLitStarCount,
            lastCompletedAt: questStore.completedQuests.compactMap(\.completedAt).max()
        )
    }

    private var state: JourneyProgress.State {
        progress.state()
    }

    private var chapterTitle: String {
        if state == .newUser { return "Chapter 1 · Your first constellation" }
        return "Chapter 2 · " + (profile.aspiration.map { "The \($0) constellation" } ?? "Your constellation")
    }

    private var displayName: String {
        profile.name.isEmpty ? "Traveler" : profile.name
    }

    /// The star the spirit stays beside. It rests on the last star once all are lit.
    private var spiritStarIndex: Int {
        progress.currentIndex ?? progress.stars.count - 1
    }

    private var spiritMood: SpiritView.Mood {
        switch state {
        case .newUser: .wave
        case .onTheWay: .focused
        case .starUnlocked, .allLit: .cheer
        case .welcomeBack: .sleepy
        }
    }

    private var spiritMessage: String {
        let count = progress.questsUntilNextStar

        switch state {
        case .newUser:
            return "Hi \(displayName)! Let’s light your first star."
        case .onTheWay:
            return count == 1 ? "One more quest and this star lights up!" : "\(spelledOut(count) ?? "\(count)") more quests and this star lights up!"
        case .starUnlocked:
            let lit = progress.stars[progress.litCount - 1].name
            guard let current = progress.currentIndex else { return "\(lit) is lit! You lit them all." }
            return "\(lit) is lit! \(progress.stars[current].name) is open."
        case .welcomeBack:
            return "Welcome back! One small quest wakes me up."
        case .allLit:
            return "Every star is lit. Look how far you’ve come!"
        }
    }

    private var bannerMessage: String {
        let count = progress.questsUntilNextStar

        switch state {
        case .newUser:
            return "Complete your first quest to light this star"
        case .onTheWay:
            let name = progress.currentIndex.map { progress.stars[$0].name } ?? ""
            return count == 1 ? "1 quest until \(name) lights up" : "\(count) quests until \(name) lights up"
        case .starUnlocked:
            guard let current = progress.currentIndex else { return "Every star in this chapter is lit" }
            return "New star: \(progress.stars[current].name) · \(progress.stars[current].goal)"
        case .welcomeBack:
            return "Your stars stay lit. Pick up where you left off"
        case .allLit:
            return "Every star in this chapter is lit"
        }
    }

    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 9) {
                    constellation
                        .frame(maxWidth: .infinity)

                    banner
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        // The new star's message shows once, then the screen moves on
        .onDisappear {
            questStore.seenLitStarCount = progress.litCount
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("YOUR PATH")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)

            Text("JOURNEY")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 4)

            Text(chapterTitle)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        // Lines up with the header on Home
        .padding(.top, 14)
        .padding(.bottom, 6)
        // Solid, so content scrolling up doesn't show behind the title
        .background(Color.asphyrBackground.ignoresSafeArea(edges: .top))
    }

    private var constellation: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Layout.backgroundDots.indices, id: \.self) { index in
                Circle()
                    .fill(Color.asphyrTextPrimary.opacity(0.35))
                    .frame(width: 2, height: 2)
                    .position(Layout.point(Layout.backgroundDots[index]))
            }

            lines

            ForEach(progress.stars.indices, id: \.self) { index in
                starNode(index)
                    .position(Layout.point(Layout.stars[index]))
            }

            spirit
        }
        .frame(width: Layout.width, height: Layout.height)
    }

    private var lines: some View {
        ZStack {
            litLines
                .stroke(Color.asphyrAccentPrimary, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .shadow(color: Color.asphyrAccentPrimary.opacity(0.6), radius: 4)

            lockedLines
                .stroke(Color.asphyrTextSecondary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
        }
        .accessibilityHidden(true)
    }

    private var litLines: Path {
        linePath { isReached($0.0) && isReached($0.1) }
    }

    private var lockedLines: Path {
        linePath { !(isReached($0.0) && isReached($0.1)) }
    }

    private func linePath(where include: ((Int, Int)) -> Bool) -> Path {
        var path = Path()
        for line in Layout.lines where include(line) {
            path.move(to: Layout.point(Layout.stars[line.0]))
            path.addLine(to: Layout.point(Layout.stars[line.1]))
        }
        return path
    }

    /// A star that's lit, or the one being worked towards.
    private func isReached(_ index: Int) -> Bool {
        index < progress.litCount || index == progress.currentIndex
    }

    @ViewBuilder
    private func starNode(_ index: Int) -> some View {
        let star = progress.stars[index]
        let isLastStar = index == progress.stars.count - 1
        let isLit = index < progress.litCount
        let isCurrent = index == progress.currentIndex
        let nodeSize: CGFloat = isLit ? 28 : isCurrent ? 40 : isLastStar ? 48 : 24

        VStack(spacing: 6) {
            Group {
                if isLit {
                    Image(star.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color.asphyrBackground)
                        .frame(width: 28, height: 28)
                        .background(Color.asphyrAccentPrimary, in: Circle())
                        .shadow(color: Color.asphyrAccentPrimary.opacity(0.5), radius: 6)
                } else if isCurrent {
                    Image(star.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                        .foregroundStyle(Color.asphyrAccentPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.asphyrBackground, in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 2.5)
                        }
                        .shadow(color: Color.asphyrAccentPrimary.opacity(0.5), radius: 14)
                } else if isLastStar {
                    Image(star.iconName)
                        .foregroundStyle(Color.asphyrWarning)
                        .frame(width: 48, height: 48)
                        .background(Color.asphyrWarning.opacity(0.12), in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(Color.asphyrWarning, lineWidth: 1.5)
                        }
                        .shadow(color: Color.asphyrWarning.opacity(0.4), radius: 14)
                } else {
                    Image("iconJourneyLock")
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .frame(width: 24, height: 24)
                        .background(Color.asphyrSurfaceElevated, in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
                        }
                }
            }
            .accessibilityHidden(true)

            Text(star.name.uppercased())
                .font(AppTypography.captionRegular)
                .foregroundStyle(labelColor(isLit: isLit, isCurrent: isCurrent, isLastStar: isLastStar))
                .multilineTextAlignment(.center)
                .frame(width: 120)
        }
        .fixedSize()
        // Centers the node on its point, with the label hanging below
        .alignmentGuide(VerticalAlignment.center) { $0[.top] + nodeSize / 2 }
        .frame(width: 120, height: nodeSize)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isLit ? "Lit" : isCurrent ? "Current" : "Locked")
    }

    private func labelColor(isLit: Bool, isCurrent: Bool, isLastStar: Bool) -> Color {
        if isLit { return .asphyrTextPrimary }
        if isCurrent { return .asphyrAccentPrimary }
        return isLastStar ? .asphyrWarning : .asphyrTextSecondary
    }

    private var spirit: some View {
        let placement = SpiritPlacement.all[spiritStarIndex]
        let bubbleY = placement.bubbleEdgeY - Layout.topOffset

        return ZStack(alignment: .topLeading) {
            SpiritView(mood: spiritMood, size: 56)
                .position(Layout.point(placement.spirit))

            Text(spiritMessage)
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextPrimary)
                // Takes the height it needs, as the frame below offers none
                .fixedSize(horizontal: false, vertical: true)
                .padding(9)
                .frame(width: placement.bubbleWidth, alignment: .leading)
                .background {
                    bubbleShape(pointyCorner: placement.pointyCorner)
                        .fill(Color.asphyrSurfaceElevated)
                        .overlay {
                            bubbleShape(pointyCorner: placement.pointyCorner)
                                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
                        }
                }
                .fixedSize(horizontal: false, vertical: true)
                // A zero-height frame lets the bubble grow away from its edge
                .frame(height: 0, alignment: placement.isAbove ? .bottom : .top)
                .offset(x: placement.bubbleX, y: bubbleY)
        }
        .frame(width: Layout.width, height: Layout.height, alignment: .topLeading)
    }

    private func bubbleShape(pointyCorner: UnitPoint) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: pointyCorner == .topLeading ? 3 : 12,
            bottomLeadingRadius: pointyCorner == .bottomLeading ? 3 : 12,
            bottomTrailingRadius: pointyCorner == .bottomTrailing ? 3 : 12,
            topTrailingRadius: pointyCorner == .topTrailing ? 3 : 12
        )
    }

    private var banner: some View {
        HStack(spacing: 10) {
            Image("iconJourneyBolt")
                .foregroundStyle(Color.asphyrAccentPrimary)
                .accessibilityHidden(true)

            Text(bannerMessage)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minHeight: 52)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private func spelledOut(_ number: Int) -> String? {
        let words = ["Two", "Three", "Four", "Five"]
        return (2...5).contains(number) ? words[number - 2] : nil
    }
}

private func completedQuests(_ count: Int, daysAgo: Double = 0) -> [Quest] {
    (0..<count).map { _ in
        var quest = Quest.sampleDaily
        quest.status = .completed
        quest.completedAt = Date(timeIntervalSinceNow: -daysAgo * 86400)
        return quest
    }
}

#Preview("New user") {
    JourneyView()
        .environment(QuestStore())
        .environment(OnboardingProfile())
}

#Preview("On the way") {
    let store = QuestStore(quests: completedQuests(3))
    store.seenLitStarCount = 2

    return JourneyView()
        .environment(store)
        .environment(OnboardingProfile())
}

#Preview("Star unlocked") {
    JourneyView()
        .environment(QuestStore(quests: completedQuests(5)))
        .environment(OnboardingProfile())
}

#Preview("Welcome back") {
    let store = QuestStore(quests: completedQuests(3, daysAgo: 4))
    store.seenLitStarCount = 2

    return JourneyView()
        .environment(store)
        .environment(OnboardingProfile())
}
