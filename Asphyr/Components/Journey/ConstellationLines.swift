//
//  ConstellationLines.swift
//  Asphyr
//

import SwiftUI

/// The lines of a constellation, drawn to fit a square.
struct ConstellationLines: Shape {
    let constellation: Constellation
    var include: ((Int, Int)) -> Bool = { _ in true }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for line in constellation.lines where include(line) {
            path.move(to: point(line.0, in: rect))
            path.addLine(to: point(line.1, in: rect))
        }
        return path
    }

    private func point(_ index: Int, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + constellation.stars[index].x * rect.width,
            y: rect.minY + constellation.stars[index].y * rect.height
        )
    }
}
