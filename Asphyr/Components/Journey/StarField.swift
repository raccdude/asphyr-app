//
//  StarField.swift
//  Asphyr
//

import SwiftUI

/// Scattered small stars that fill their space. The seed keeps them in the same
/// places every time, so the sky doesn't change between visits.
struct StarField: View {
    var count = 150
    var seed: UInt64 = 7

    var body: some View {
        Canvas { context, size in
            var value = seed

            func next() -> CGFloat {
                // A small, repeatable random number generator
                value = value &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
                return CGFloat((value >> 33) % 10_000) / 10_000
            }

            for _ in 0..<count {
                let point = CGPoint(x: next() * size.width, y: next() * size.height)
                let brightness = next()
                // Mostly tiny and faint, with the occasional brighter star
                let diameter = 1 + brightness * brightness * 1.8
                let rect = CGRect(x: point.x, y: point.y, width: diameter, height: diameter)

                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(Color.asphyrTextPrimary.opacity(0.12 + brightness * 0.43))
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview(traits: .dark) {
    StarField()
        .background(Color.asphyrBackground)
}
