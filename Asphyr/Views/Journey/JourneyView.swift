//
//  JourneyView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct JourneyView: View {
    @Environment(QuestStore.self) private var questStore
    @Environment(OnboardingProfile.self) private var profile

    @State private var isShowingSky = false
    /// The star whose details the guide card is showing.
    @State private var selectedStar: Int?
    @State private var lockedTapCount = 0
    @State private var selectionCount = 0
    @State private var starShakes: [Int: Int] = [:]

    /// The chapter being looked at. Nil follows the user's current chapter.
    @State private var viewedChapter: Int?

    private var chapters: [JourneyPath] {
        JourneyPath.chapters(for: profile.aspiration)
    }

    private var completedCount: Int {
        questStore.completedQuests.count
    }

    private var currentChapter: Int {
        JourneyChapters.currentIndex(completedQuests: completedCount)
    }

    private var chapterIndex: Int {
        viewedChapter ?? currentChapter
    }

    private var path: JourneyPath {
        chapters[chapterIndex]
    }

    /// Every star lit so far, across all chapters.
    private var totalLitStars: Int {
        chapters.indices.reduce(0) { total, index in
            total + chapterProgress(index, seen: 0).litCount
        }
    }

    private func litStarsBefore(chapter: Int) -> Int {
        (0..<chapter).reduce(0) { $0 + chapters[$1].stars.count }
    }

    private func chapterProgress(_ index: Int, seen: Int) -> JourneyProgress {
        JourneyProgress(
            stars: chapters[index].stars,
            completedQuests: JourneyChapters.quests(completedQuests: completedCount, inChapter: index),
            litStarsAlreadySeen: seen,
            lastCompletedAt: questStore.completedQuests.compactMap(\.completedAt).max(),
            chapterIndex: index,
            hasChapterNews: questStore.seenLitStarCount < totalLitStarsUpTo(index)
        )
    }

    private func totalLitStarsUpTo(_ chapter: Int) -> Int {
        litStarsBefore(chapter: chapter)
    }

    private var constellation: Constellation {
        path.constellation
    }

    private var progress: JourneyProgress {
        // Stars already seen, counted within this chapter. A past chapter opened
        // from the sky map has no news to announce.
        let seen = viewedChapter == nil || viewedChapter == currentChapter
            ? max(0, questStore.seenLitStarCount - litStarsBefore(chapter: chapterIndex))
            : chapters[chapterIndex].stars.count

        return chapterProgress(chapterIndex, seen: seen)
    }

    private var layout: JourneyLayout {
        JourneyLayout(
            constellation: constellation,
            names: progress.stars.map(\.name),
            litCount: progress.litCount,
            currentIndex: progress.currentIndex
        )
    }

    private var state: JourneyProgress.State {
        progress.state()
    }

    private var chapterTitle: String {
        "Chapter \(chapterIndex + 1) · \(constellation.name)"
    }

    private var displayName: String {
        profile.name.isEmpty ? "Traveler" : profile.name
    }

    private var spiritMood: SpiritView.Mood {
        switch state {
        case .newUser: .wave
        case .onTheWay: .focused
        case .starUnlocked, .allLit, .chapterComplete, .chapterStart: .cheer
        case .welcomeBack: .sleepy
        }
    }

    private var spiritMessage: String {
        let count = progress.questsUntilNextStar

        switch state {
        case .newUser:
            return "Hi \(displayName)! Let’s light a star!"
        case .onTheWay:
            return count == 1 ? "One more quest to light it up!" : "\(spelledOut(count)) more quests to light it up!"
        case .starUnlocked:
            let lit = progress.stars[progress.litCount - 1].name
            guard let current = progress.currentIndex else { return "\(lit) is lit! You lit them all." }
            return "\(lit) is lit! \(progress.stars[current].name) is open."
        case .welcomeBack:
            return "Welcome back! One small quest wakes me up."
        case .allLit:
            return "Every star is lit. Look how far you’ve come!"
        case .chapterComplete:
            return "Chapter \(chapterIndex) is complete. Look how far you’ve come!"
        case .chapterStart:
            return "A new constellation to light. Let’s go!"
        }
    }

    private func spelledOut(_ number: Int) -> String {
        let words = ["Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]
        return (2...10).contains(number) ? words[number - 2] : "\(number)"
    }

    /// What's next, so the card says something the spirit's message doesn't.
    private var nextStepMessage: String {
        if state == .starUnlocked, let current = progress.currentIndex {
            return progress.stars[current].goal
        }
        if state == .chapterComplete {
            return "Next: Chapter \(chapterIndex + 1), \(constellation.name)."
        }
        guard let current = progress.currentIndex else {
            return chapterIndex == JourneyChapters.count - 1 ? "You finished all 5 chapters." : "This chapter is complete."
        }
        return "Next: \(progress.stars[current].name)."
    }

    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            StarField()

            if isShowingSky {
                JourneySkyMap(
                    chapters: chapters.map(\.constellation),
                    spots: JourneySkyLayout.spots(for: profile.aspiration),
                    currentChapter: currentChapter,
                    completedQuests: completedCount
                ) { chapter in
                    // The current chapter follows the user as they progress
                    viewedChapter = chapter == currentChapter ? nil : chapter
                    selectedStar = nil
                    setSkyVisible(false)
                }
                .padding(.bottom, 24)
                .transition(.scale(scale: 1.4).combined(with: .opacity))
            } else {
                ScrollView {
                    constellationView
                        .frame(maxWidth: .infinity)
                        // Centers the constellation in the space it has
                        .containerRelativeFrame(.vertical)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    guideCard
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                }
                .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
        }
        .simultaneousGesture(
            MagnifyGesture().onEnded { value in
                // Pinching out shows the sky, and pinching in comes back
                if value.magnification < 0.85 {
                    setSkyVisible(true)
                } else if value.magnification > 1.15 {
                    setSkyVisible(false)
                }
            }
        )
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .hapticFeedback(.warning, trigger: lockedTapCount)
        .task(id: selectionCount) {
            guard selectedStar != nil else { return }

            do {
                try await Task.sleep(for: .seconds(4))
                selectedStar = nil
            } catch {
                // A newer tap restarted the delay
            }
        }
        .onDisappear {
            // The new star's message shows once, so it only counts as seen if
            // the constellation was showing
            if !isShowingSky, viewedChapter == nil {
                questStore.seenLitStarCount = totalLitStars
            }
            isShowingSky = false
            viewedChapter = nil
            selectedStar = nil
        }
    }

    private func setSkyVisible(_ isVisible: Bool) {
        withAnimation(.smooth(duration: 0.4)) {
            isShowingSky = isVisible
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
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
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .padding(.top, 8)

                Text(constellation.meaning)
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .padding(.top, 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                setSkyVisible(!isShowingSky)
            } label: {
                Image(systemName: isShowingSky ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .glassEffect(.regular.interactive(), in: Circle())
            // Dark glass until the app's light colors exist
            .environment(\.colorScheme, .dark)
            .accessibilityLabel(isShowingSky ? "Back to this constellation" : "See the whole sky")
        }
        .padding(.horizontal, 20)
        // Lines up with the header on Home
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var constellationView: some View {
        let layout = layout

        return ZStack(alignment: .topLeading) {
            lines

            ForEach(progress.stars.indices, id: \.self) { index in
                starNode(index)
                    .position(JourneyLayout.starPoint(constellation, index))
                    // The current star is never hidden by a neighbor
                    .zIndex(index == progress.currentIndex ? 1 : 0)
            }

            ForEach(Array(layout.labels.keys), id: \.self) { index in
                starLabel(index)
                    .position(layout.labels[index] ?? .zero)
            }
            .zIndex(2)
        }
        .frame(width: JourneyLayout.width, height: JourneyLayout.height)
    }

    private var lines: some View {
        ZStack {
            ConstellationLines(constellation: constellation) { isReached($0.0) && isReached($0.1) }
                .stroke(Color.asphyrAccentPrimary, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .shadow(color: Color.asphyrAccentPrimary.opacity(0.6), radius: 4)

            ConstellationLines(constellation: constellation) { !(isReached($0.0) && isReached($0.1)) }
                .stroke(Color.asphyrTextSecondary.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
        }
        .frame(width: JourneyLayout.shapeSize, height: JourneyLayout.shapeSize)
        .offset(x: JourneyLayout.origin.x, y: JourneyLayout.origin.y)
        .accessibilityHidden(true)
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

        Group {
            if isLit {
                Button {
                    select(index)
                } label: {
                    Image(star.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color.asphyrBackground)
                        .frame(width: 28, height: 28)
                        .background(Color.asphyrAccentPrimary, in: Circle())
                        .shadow(color: Color.asphyrAccentPrimary.opacity(0.5), radius: 6)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            } else if isCurrent {
                Button {
                    select(index)
                } label: {
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
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    tapLockedStar(index)
                } label: {
                    lockedNode(star, isLastStar: isLastStar)
                        .modifier(ShakeEffect(shakes: CGFloat(starShakes[index, default: 0])))
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(star.name)
        .accessibilityValue(isLit ? "Lit" : isCurrent ? "Current" : "Locked")
    }

    @ViewBuilder
    private func lockedNode(_ star: JourneyStar, isLastStar: Bool) -> some View {
        if isLastStar {
            Image(star.iconName)
                .foregroundStyle(Color.asphyrWarning)
                .frame(width: 48, height: 48)
                .background(Color.asphyrWarning.opacity(0.12), in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.asphyrWarning, lineWidth: 1.5)
                }
                .shadow(color: Color.asphyrWarning.opacity(0.4), radius: 14)
                .contentShape(Circle())
        } else {
            Image("iconJourneyLock")
                .foregroundStyle(Color.asphyrTextSecondary)
                .frame(width: 24, height: 24)
                .background(Color.asphyrSurfaceElevated, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.asphyrTextSecondary.opacity(0.6), lineWidth: 1)
                }
                // A larger target that still leaves close neighbors tappable
                .frame(width: 36, height: 36)
                .contentShape(Circle())
        }
    }

    private func tapLockedStar(_ index: Int) {
        withAnimation(.linear(duration: 0.4)) {
            starShakes[index, default: 0] += 1
        }
        select(index)
        lockedTapCount += 1
    }

    private func select(_ index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedStar = index
        }
        selectionCount += 1
    }

    private func starLabel(_ index: Int) -> some View {
        let isLastStar = index == progress.stars.count - 1
        let color: Color = index < progress.litCount
            ? .asphyrTextPrimary
            : index == progress.currentIndex ? .asphyrAccentPrimary : isLastStar ? .asphyrWarning : .asphyrTextSecondary

        return Text(progress.stars[index].name.uppercased())
            .font(AppTypography.captionRegular)
            .foregroundStyle(color)
            .lineLimit(1)
            .fixedSize()
            .accessibilityHidden(true)
    }

    /// The flame spirit guides from one place, and tapping a star shows its
    /// details here for a few seconds.
    private var guideCard: some View {
        HStack(spacing: 12) {
            SpiritView(mood: spiritMood, size: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(guideTitle)
                    .font(AppTypography.bodySecondarySemiBold)
                    .foregroundStyle(Color.asphyrTextPrimary)

                Text(guideDetail)
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(selectedStar)
            .transition(.opacity)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 76)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var guideTitle: String {
        guard let selectedStar else { return spiritMessage }
        return progress.stars[selectedStar].name
    }

    private var guideDetail: String {
        guard let selectedStar else { return nextStepMessage }

        let star = progress.stars[selectedStar]
        if selectedStar < progress.litCount { return "Lit. \(star.goal)." }

        let questsLeft = star.questsNeeded - progress.completedQuests
        return "\(questsLeft) to go. \(star.goal)."
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

private func journeyPreview(aspiration: String?, completed: Int = 3, daysAgo: Double = 0, seen: Int = 99) -> some View {
    let store = QuestStore(quests: completedQuests(completed, daysAgo: daysAgo))
    store.seenLitStarCount = seen

    let profile = OnboardingProfile()
    profile.aspiration = aspiration

    return JourneyView()
        .environment(store)
        .environment(profile)
}

#Preview("New user", traits: .dark) { journeyPreview(aspiration: "Doctor", completed: 0, seen: 0) }
#Preview("Star unlocked", traits: .dark) { journeyPreview(aspiration: "Doctor", completed: 5, seen: 0) }
#Preview("Welcome back", traits: .dark) { journeyPreview(aspiration: "Doctor", daysAgo: 4) }
#Preview("Chapter complete", traits: .dark) { journeyPreview(aspiration: "Doctor", completed: 20, seen: 0) }
#Preview("Chapter 2", traits: .dark) { journeyPreview(aspiration: "Doctor", completed: 25) }
#Preview("All lit", traits: .dark) { journeyPreview(aspiration: "Doctor", completed: 100) }

#Preview("Doctor", traits: .dark) { journeyPreview(aspiration: "Doctor") }
#Preview("Musician", traits: .dark) { journeyPreview(aspiration: "Musician") }
#Preview("Teacher", traits: .dark) { journeyPreview(aspiration: "Teacher") }
#Preview("Athlete", traits: .dark) { journeyPreview(aspiration: "Athlete") }
#Preview("Entrepreneur", traits: .dark) { journeyPreview(aspiration: "Entrepreneur") }
#Preview("Mechanical Engineer", traits: .dark) { journeyPreview(aspiration: "Mechanical Engineer") }
#Preview("Engineer", traits: .dark) { journeyPreview(aspiration: "Engineer") }
#Preview("Designer", traits: .dark) { journeyPreview(aspiration: "Designer") }
#Preview("Game Developer", traits: .dark) { journeyPreview(aspiration: "Game Developer") }
#Preview("Artist", traits: .dark) { journeyPreview(aspiration: "Artist") }
#Preview("Writer", traits: .dark) { journeyPreview(aspiration: "Writer") }
#Preview("Psychologist", traits: .dark) { journeyPreview(aspiration: "Psychologist") }
#Preview("Custom", traits: .dark) { journeyPreview(aspiration: "Marine Biologist") }
