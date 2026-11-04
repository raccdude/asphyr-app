//
//  XPBar.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

struct XPBar: View {
    enum Motion {
        /// The gradient keeps moving along the bar.
        case flowing
        case still
        /// Fills once when it appears, for screens with many bars.
        case fillsOnAppear
    }

    /// From 0 to 1.
    var progress: CGFloat = 0
    var height: CGFloat = 8
    var trackColor: Color = .asphyrSurfaceElevated
    var motion: Motion = .flowing

    private static let secondsPerLoop = 3.2
    /// Starts and ends on the same color, so the loop has no seam.
    private static let gradient = LinearGradient(
        colors: [.asphyrGradientDeep, .asphyrGradientLight, .asphyrGradientDeep],
        startPoint: .leading,
        endPoint: .trailing
    )

    @State private var hasAppeared = false

    private var shownProgress: CGFloat {
        motion == .fillsOnAppear && !hasAppeared ? 0 : progress
    }

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(trackColor)
            .frame(height: height)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    fill(trackWidth: proxy.size.width)
                        .frame(width: proxy.size.width * shownProgress, alignment: .leading)
                        .clipShape(Capsule())
                        .shadow(color: Color.asphyrAccentPrimary.opacity(0.5), radius: 6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: height / 2))
            .onAppear {
                guard motion == .fillsOnAppear else { return }
                withAnimation(.easeOut(duration: 0.8)) {
                    hasAppeared = true
                }
            }
    }

    @ViewBuilder
    private func fill(trackWidth: CGFloat) -> some View {
        if motion == .flowing {
            TimelineView(.animation(minimumInterval: 1 / 30)) { context in
                let loop = context.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: Self.secondsPerLoop) / Self.secondsPerLoop

                HStack(spacing: 0) {
                    Self.gradient.frame(width: trackWidth)
                    Self.gradient.frame(width: trackWidth)
                }
                .offset(x: (loop - 1) * trackWidth)
            }
        } else {
            Self.gradient.frame(width: trackWidth * 2)
        }
    }
}

#Preview(traits: .dark) {
    XPBar()
}
