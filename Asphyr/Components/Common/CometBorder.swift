//
//  CometBorder.swift
//  Asphyr
//

import SwiftUI

/// An active card's outline: a point of light travels clockwise around it,
/// with a fading tail, over a faint green edge.
struct CometBorder: View {
    let cornerRadius: CGFloat

    private static let secondsPerLap = 5.0
    private static let stops: [Gradient.Stop] = [
        .init(color: .clear, location: 0.72),
        .init(color: .asphyrAccentPrimary.opacity(0.15), location: 0.8),
        .init(color: .asphyrAccentPrimary, location: 0.97),
        .init(color: Color(red: 216 / 255, green: 1, blue: 228 / 255), location: 1)  // #D8FFE4
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            let lap = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: Self.secondsPerLap) / Self.secondsPerLap

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.asphyrAccentPrimary.opacity(0.25), lineWidth: 1)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        AngularGradient(stops: Self.stops, center: .center, angle: .degrees(lap * 360)),
                        lineWidth: 1.5
                    )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 16)
        .fill(Color.asphyrSurfaceElevated)
        .frame(height: 200)
        .overlay {
            CometBorder(cornerRadius: 16)
        }
        .padding(20)
        .background(Color.asphyrBackground)
}
