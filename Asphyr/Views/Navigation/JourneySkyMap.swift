//
//  JourneySkyMap.swift
//  Asphyr
//

import SwiftUI

/// The zoomed-out sky, with the journey's chapters along a path from the center. Reached chapters
/// can be opened, and later ones are faint, unnamed shapes.
struct JourneySkyMap: View {
    let chapters: [Constellation]
    /// Where each chapter sits, as fractions of the map.
    let spots: [CGPoint]
    let currentChapter: Int
    let completedQuests: Int
    let onOpen: (Int) -> Void

    private static let shapeSize: CGFloat = 104

    @State private var shakes = [Int](repeating: 0, count: JourneyChapters.count)
    @State private var showsToast = false
    @State private var toastCount = 0

    var body: some View {
        GeometryReader { proxy in
            let points = spots.map { CGPoint(x: $0.x * proxy.size.width, y: $0.y * proxy.size.height) }

            ZStack {
                // Denser than the constellation view, as this is further out
                StarField(count: 170, seed: 23)

                Path { path in
                    path.addLines(points)
                }
                .stroke(Color.asphyrTextSecondary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
                .accessibilityHidden(true)

                ForEach(chapters.indices, id: \.self) { index in
                    chapterView(index)
                        .position(points[index])
                }
            }
        }
        .overlay(alignment: .top) {
            if showsToast {
                AsphyrToast(icon: "iconAlert", message: "This chapter opens later.")
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showsToast)
        .sensoryFeedback(.warning, trigger: toastCount)
        .task(id: toastCount) {
            guard showsToast else { return }

            do {
                try await Task.sleep(for: .seconds(3))
                showsToast = false
            } catch {
                // A newer tap restarted the delay
            }
        }
    }

    @ViewBuilder
    private func chapterView(_ index: Int) -> some View {
        if index <= currentChapter {
            Button {
                onOpen(index)
            } label: {
                reachedChapter(index)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Chapter \(index + 1), \(chapters[index].name)")
            .accessibilityValue(index == currentChapter ? "Current" : "Complete")
        } else {
            Button {
                withAnimation(.linear(duration: 0.4)) {
                    shakes[index] += 1
                }
                showsToast = true
                toastCount += 1
            } label: {
                ConstellationLines(constellation: chapters[index])
                    .stroke(Color.asphyrTextSecondary.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                    .frame(width: Self.shapeSize, height: Self.shapeSize)
                    .contentShape(Rectangle())
                    .modifier(ShakeEffect(shakes: CGFloat(shakes[index])))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Chapter \(index + 1), locked")
        }
    }

    private func reachedChapter(_ index: Int) -> some View {
        let constellation = chapters[index]
        let litQuests = JourneyChapters.quests(completedQuests: completedQuests, inChapter: index)
        let thresholds = JourneyPath.questThresholds(starCount: constellation.stars.count)
        let isCurrent = index == currentChapter

        return VStack(spacing: 6) {
            ZStack {
                ConstellationLines(constellation: constellation)
                    .stroke(Color.asphyrAccentPrimary.opacity(isCurrent ? 0.8 : 0.5), lineWidth: isCurrent ? 1.5 : 1)
                    .shadow(color: Color.asphyrAccentPrimary.opacity(isCurrent ? 0.5 : 0), radius: 6)

                GeometryReader { proxy in
                    ForEach(constellation.stars.indices, id: \.self) { star in
                        Circle()
                            .fill(litQuests >= thresholds[star] ? Color.asphyrAccentPrimary : Color.asphyrTextSecondary)
                            .frame(width: 6, height: 6)
                            .position(
                                x: constellation.stars[star].x * proxy.size.width,
                                y: constellation.stars[star].y * proxy.size.height
                            )
                    }
                }
            }
            .frame(width: Self.shapeSize, height: Self.shapeSize)

            Text(constellation.name.uppercased())
                .font(AppTypography.captionRegular)
                .foregroundStyle(isCurrent ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
                .lineLimit(1)
                .fixedSize()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    JourneySkyMap(
        chapters: JourneyPath.chapters(for: "Musician").map(\.constellation),
        spots: JourneySkyLayout.spots(for: "Musician"),
        currentChapter: 1,
        completedQuests: 27
    ) { _ in }
    .background(Color.asphyrBackground)
}
