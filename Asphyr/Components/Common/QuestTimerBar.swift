//
//  QuestTimerBar.swift
//  Asphyr
//

import SwiftUI

/// A timed quest's progress, with a glowing dot at its leading edge.
struct QuestTimerBar: View {
    /// From 0 to 1.
    let progress: Double
    let isPaused: Bool
    var trackColor: Color = .asphyrSurfaceElevated

    private static let dotSize: CGFloat = 14

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .leading) {
                XPBar(progress: progress, height: 6, trackColor: trackColor, motion: isPaused ? .still : .flowing)

                Circle()
                    .fill(isPaused ? Color.asphyrTextSecondary : Color.asphyrAccentPrimary)
                    .frame(width: Self.dotSize, height: Self.dotSize)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.asphyrSurface, lineWidth: 3)
                    }
                    .shadow(color: isPaused ? .clear : Color.asphyrAccentPrimary.opacity(0.5), radius: 5)
                    .offset(x: min(width - Self.dotSize, max(0, width * progress - Self.dotSize / 2)))
            }
            .frame(height: Self.dotSize)
            .animation(.linear(duration: 1), value: progress)
        }
        .frame(height: Self.dotSize)
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 24) {
        QuestTimerBar(progress: 0, isPaused: false)
        QuestTimerBar(progress: 0.43, isPaused: false)
        QuestTimerBar(progress: 0.43, isPaused: true)
        QuestTimerBar(progress: 1, isPaused: false)
    }
    .padding(20)
    .background(Color.asphyrSurface)
}
