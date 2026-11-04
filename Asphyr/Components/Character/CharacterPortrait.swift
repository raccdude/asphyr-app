//
//  CharacterPortrait.swift
//  Asphyr
//

import SwiftUI

/// The character with a mood drawn over its face. The face sits on its own
/// layer so one set of moods works for every color and archetype image.
struct CharacterPortrait: View {
    enum Mood: CaseIterable {
        case idle
        case happy
        case sleepy
        case focused
        /// Only from too many quick taps, so it's not part of the cycle.
        case angry

        var next: Mood {
            let moods: [Mood] = [.idle, .happy, .sleepy, .focused]
            let index = moods.firstIndex(of: self) ?? 0
            return moods[(index + 1) % moods.count]
        }

        var faceImageName: String? {
            switch self {
            case .idle: nil
            case .happy: "characterFaceHappy"
            case .sleepy: "characterFaceSleepy"
            case .focused: "characterFaceFocused"
            case .angry: "characterFaceAngry"
            }
        }
    }

    let color: CharacterColor
    var archetype: Archetype?
    var cloak: CharacterCloak?
    var mood: Mood = .idle
    var size: CGFloat = 126
    /// Goes up with each tap, for the bounce and ripple.
    var tapCount = 0

    var body: some View {
        ZStack {
            if mood == .angry {
                AngryFlames(color: color)
                    .transition(.opacity)
            }

            CharacterArt(color: color, archetype: archetype, cloak: cloak)

            if let faceImageName = mood.faceImageName {
                layer("characterFaceVisor")

                layer(faceImageName)
                    .foregroundStyle(color.faceColor)
                    .id(mood)
                    .transition(.opacity)
            }

            if mood == .sleepy {
                layer("characterSleepyZs")
                    .transition(.opacity)
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.2), value: mood)
        // A little bounce and a ripple in the user's color, only when tapped
        .keyframeAnimator(initialValue: TapEffect(), trigger: tapCount) { content, effect in
            content
                .scaleEffect(effect.scale)
                .background {
                    Circle()
                        .stroke(color.faceColor, lineWidth: 2)
                        .scaleEffect(effect.rippleScale)
                        .opacity(effect.rippleOpacity)
                }
        } keyframes: { _ in
            KeyframeTrack(\.scale) {
                SpringKeyframe(1.08, duration: 0.14)
                SpringKeyframe(1, duration: 0.3)
            }
            KeyframeTrack(\.rippleScale) {
                CubicKeyframe(0.55, duration: 0.01)
                CubicKeyframe(1.1, duration: 0.45)
            }
            KeyframeTrack(\.rippleOpacity) {
                CubicKeyframe(0.45, duration: 0.01)
                CubicKeyframe(0, duration: 0.45)
            }
        }
    }

    private struct TapEffect {
        var scale: CGFloat = 1
        var rippleScale: CGFloat = 0.55
        var rippleOpacity: Double = 0
    }

    private func layer(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
    }
}

/// Flames flickering around an angry character.
private struct AngryFlames: View {
    let color: CharacterColor

    /// Position as fractions of the portrait, and size as a fraction of it.
    private static let flames: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.16, 0.74, 0.3), (0.84, 0.74, 0.3), (0.08, 0.46, 0.22), (0.92, 0.46, 0.22),
        (0.3, 0.1, 0.2), (0.7, 0.1, 0.2), (0.5, 0.02, 0.26)
    ]

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1 / 20)) { context in
                let time = context.date.timeIntervalSinceReferenceDate

                // Without the ZStack, TimelineView stacks the flames vertically
                ZStack {
                    ForEach(Self.flames.indices, id: \.self) { index in
                        let flame = Self.flames[index]
                        let flicker = sin(time * 9 + Double(index) * 1.7)
                        let side = proxy.size.width * flame.size

                        ZStack {
                            FlameShape(part: .outer)
                                .fill(
                                    // Bright at the tip, so dark colors still show against the background
                                    LinearGradient(colors: [color.faceColor, color.swatch], startPoint: .top, endPoint: .bottom)
                                )

                            FlameShape(part: .inner)
                                .stroke(color.flameOutline, style: StrokeStyle(lineWidth: side * 1.1 / 24, lineJoin: .round))
                        }
                        .frame(width: side, height: side)
                        .scaleEffect(1 + flicker * 0.14, anchor: .bottom)
                        .opacity(0.8 + flicker * 0.2)
                        .position(x: proxy.size.width * flame.x, y: proxy.size.height * flame.y)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}

/// A flame drawn on a 24pt grid, matching Figma's `20.7` sheet.
private struct FlameShape: Shape {
    enum Part {
        case outer
        /// The outline inside the flame, for detail.
        case inner
    }

    let part: Part

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scale = min(rect.width, rect.height) / 24

        switch part {
        case .outer:
            path.move(to: CGPoint(x: 12, y: 1.5))
            path.addCurve(to: CGPoint(x: 18.5, y: 15.5), control1: CGPoint(x: 13, y: 6), control2: CGPoint(x: 18.5, y: 9))
            path.addArc(center: CGPoint(x: 12, y: 15.5), radius: 6.5, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            path.addCurve(to: CGPoint(x: 8.5, y: 8.5), control1: CGPoint(x: 5.5, y: 12.5), control2: CGPoint(x: 7.5, y: 11.5))
            path.addCurve(to: CGPoint(x: 12, y: 1.5), control1: CGPoint(x: 10, y: 10), control2: CGPoint(x: 11, y: 8))
        case .inner:
            path.move(to: CGPoint(x: 12, y: 8.5))
            path.addCurve(to: CGPoint(x: 15.5, y: 16), control1: CGPoint(x: 12.6, y: 11), control2: CGPoint(x: 15.5, y: 12.8))
            path.addArc(center: CGPoint(x: 12, y: 16), radius: 3.5, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            path.addCurve(to: CGPoint(x: 10, y: 12.5), control1: CGPoint(x: 8.5, y: 14.5), control2: CGPoint(x: 9.5, y: 13.8))
            path.addCurve(to: CGPoint(x: 12, y: 8.5), control1: CGPoint(x: 10.8, y: 13.2), control2: CGPoint(x: 11.6, y: 11.8))
        }
        path.closeSubpath()

        return path
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

#Preview("Angry") {
    CharacterPortrait(color: .green, archetype: .strategist, mood: .angry)
        .padding(40)
        .background(Color.asphyrBackground)
}

#Preview {
    HStack {
        ForEach(CharacterPortrait.Mood.allCases, id: \.self) { mood in
            CharacterPortrait(color: .green, mood: mood)
        }
    }
    .background(Color.asphyrBackground)
}
