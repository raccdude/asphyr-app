//
//  JourneyLayout.swift
//  Asphyr
//

import CoreGraphics
import Foundation

/// Works out where the stars and their labels go on any constellation.
struct JourneyLayout {
    static let width: CGFloat = 402
    static let height: CGFloat = 420
    /// The constellation fills a square, leaving room for labels.
    static let shapeSize: CGFloat = 340
    static let origin = CGPoint(x: (width - shapeSize) / 2, y: (height - shapeSize) / 2)
    private static let margin: CGFloat = 8

    /// The centers of the labels with room to show, by star.
    let labels: [Int: CGPoint]
    private let labelWidths: [CGFloat]

    func labelRect(_ index: Int) -> CGRect {
        Self.rect(center: labels[index] ?? .zero, width: labelWidths[index])
    }

    static func starPoint(_ constellation: Constellation, _ index: Int) -> CGPoint {
        CGPoint(
            x: origin.x + constellation.stars[index].x * shapeSize,
            y: origin.y + constellation.stars[index].y * shapeSize
        )
    }

    static func starRect(_ constellation: Constellation, _ index: Int, size: CGFloat) -> CGRect {
        let point = starPoint(constellation, index)
        return CGRect(x: point.x - size / 2, y: point.y - size / 2, width: size, height: size)
    }

    static func nodeSize(_ index: Int, litCount: Int, currentIndex: Int?, count: Int) -> CGFloat {
        if index < litCount { return 28 }
        if index == currentIndex { return 40 }
        return index == count - 1 ? 48 : 24
    }

    private static func rect(center: CGPoint, width: CGFloat) -> CGRect {
        CGRect(x: center.x - width / 2, y: center.y - 7, width: width, height: 14)
    }

    init(constellation: Constellation, names: [String], litCount: Int, currentIndex: Int?) {
        let count = names.count
        let nodeRects = names.indices.map { index in
            Self.starRect(constellation, index, size: Self.nodeSize(index, litCount: litCount, currentIndex: currentIndex, count: count))
        }
        let widths = names.map { CGFloat($0.count) * 6.6 + 4 }
        labelWidths = widths

        // The current star and the destination always get a label, then lit
        // stars, then locked ones, which are named when tapped instead
        let essential = [currentIndex, count - 1].compactMap { $0 }
        let order = essential + Array((0..<litCount).reversed()) + Array(0..<count)
        var placed: [Int: CGPoint] = [:]

        for index in order where placed[index] == nil {
            let node = nodeRects[index]
            let halfWidth = widths[index] / 2
            let x = min(max(node.midX, Self.margin + halfWidth), Self.width - Self.margin - halfWidth)
            let spots = [
                CGPoint(x: x, y: node.maxY + 12),
                CGPoint(x: x, y: node.minY - 12)
            ]
            let isEssential = essential.contains(index)
            let isClear: (CGPoint) -> Bool = { spot in
                let rect = Self.rect(center: spot, width: widths[index])
                let hitsStar = nodeRects.indices.contains { $0 != index && nodeRects[$0].intersects(rect) }
                let hitsLabel = placed.contains { Self.rect(center: $0.value, width: widths[$0.key]).intersects(rect) }
                return !hitsStar && !hitsLabel
            }

            if let spot = spots.first(where: isClear) {
                placed[index] = spot
            } else if isEssential {
                placed[index] = spots[0]
            }
        }
        labels = placed
    }
}
