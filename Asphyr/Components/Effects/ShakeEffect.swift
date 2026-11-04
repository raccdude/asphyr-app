//
//  ShakeEffect.swift
//  Asphyr
//

import SwiftUI

/// Shakes a view once each time `shakes` goes up by one inside an animation.
struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(shakes * .pi * 3) * 6, y: 0))
    }
}
