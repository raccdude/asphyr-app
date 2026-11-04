//
//  ConstellationData.swift
//  Asphyr
//
//  Generated from the d3-celestial star data by Olaf Frohn (see
//  Resources/d3-celestial-LICENSE.txt). Don't edit positions by hand.
//

import CoreGraphics
import Foundation

/// A real constellation. `stars` run in the order they light, from 0 to 1 across
/// the shape as it's seen from Earth, and `lines` are its real connections.
struct Constellation {
    let id: String
    let name: String
    let meaning: String
    let stars: [CGPoint]
    let lines: [(Int, Int)]

    static let all: [String: Constellation] = [
        "Oph": Constellation(
            id: "Oph",
            name: "Ophiuchus",
            meaning: "Asclepius, the god of medicine",
            stars: [
                CGPoint(x: 0.4359, y: 1.0),
                CGPoint(x: 0.4637, y: 0.8764),
                CGPoint(x: 0.5268, y: 0.6575),
                CGPoint(x: 0.7135, y: 0.5443),
                CGPoint(x: 0.7439, y: 0.6857),
                CGPoint(x: 0.6039, y: 0.0796),
                CGPoint(x: 0.3391, y: 0.1955),
                CGPoint(x: 0.2561, y: 0.5259),
                CGPoint(x: 0.3865, y: 0.0)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (2, 6), (3, 4), (3, 5), (5, 8), (6, 7), (6, 8)]
        ),
        "Lyr": Constellation(
            id: "Lyr",
            name: "Lyra",
            meaning: "The lyre of Orpheus",
            stars: [
                CGPoint(x: 0.177, y: 1.0),
                CGPoint(x: 0.4482, y: 0.9062),
                CGPoint(x: 0.6032, y: 0.2912),
                CGPoint(x: 0.3225, y: 0.3925),
                CGPoint(x: 0.6116, y: 0.0),
                CGPoint(x: 0.823, y: 0.1159)
            ],
            lines: [(0, 1), (0, 3), (1, 2), (2, 3), (2, 4), (2, 5), (4, 5)]
        ),
        "Cen": Constellation(
            id: "Cen",
            name: "Centaurus",
            meaning: "Chiron, who taught the Greek heroes",
            stars: [
                CGPoint(x: 0.5736, y: 0.01),
                CGPoint(x: 0.3486, y: 0.2066),
                CGPoint(x: 0.2033, y: 0.0),
                CGPoint(x: 0.3156, y: 0.4286),
                CGPoint(x: 0.4198, y: 0.6685),
                CGPoint(x: 0.3014, y: 0.9519),
                CGPoint(x: 0.7962, y: 0.5273),
                CGPoint(x: 0.8722, y: 0.5956),
                CGPoint(x: 0.1278, y: 1.0)
            ],
            lines: [(0, 1), (1, 2), (1, 3), (3, 4), (4, 5), (4, 6), (4, 8), (6, 7)]
        ),
        "Her": Constellation(
            id: "Her",
            name: "Hercules",
            meaning: "The hero of the twelve labors",
            stars: [
                CGPoint(x: 0.6654, y: 0.0),
                CGPoint(x: 0.5915, y: 0.129),
                CGPoint(x: 0.5427, y: 0.2397),
                CGPoint(x: 0.3471, y: 0.2991),
                CGPoint(x: 0.4325, y: 0.4828),
                CGPoint(x: 0.556, y: 0.4629),
                CGPoint(x: 0.6407, y: 0.7719),
                CGPoint(x: 0.3069, y: 1.0)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (2, 5), (3, 4), (4, 5), (5, 6), (6, 7)]
        ),
        "Vel": Constellation(
            id: "Vel",
            name: "Vela",
            meaning: "The sails of the Argo, a great venture",
            stars: [
                CGPoint(x: 0.729, y: 0.7822),
                CGPoint(x: 0.5217, y: 0.7747),
                CGPoint(x: 0.3293, y: 0.7647),
                CGPoint(x: 0.0, y: 0.623),
                CGPoint(x: 0.1585, y: 0.3035),
                CGPoint(x: 0.4718, y: 0.2178),
                CGPoint(x: 0.6298, y: 0.3368),
                CGPoint(x: 1.0, y: 0.5478)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7)]
        ),
        "Hor": Constellation(
            id: "Hor",
            name: "Horologium",
            meaning: "The pendulum clock",
            stars: [
                CGPoint(x: 0.7565, y: 1.0),
                CGPoint(x: 0.7298, y: 0.7852),
                CGPoint(x: 0.8906, y: 0.5384),
                CGPoint(x: 0.9222, y: 0.443),
                CGPoint(x: 0.0778, y: 0.0)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (3, 4)]
        ),
        "Aur": Constellation(
            id: "Aur",
            name: "Auriga",
            meaning: "Erichthonius, inventor of the four-horse chariot",
            stars: [
                CGPoint(x: 0.5132, y: 1.0),
                CGPoint(x: 0.7463, y: 0.8097),
                CGPoint(x: 0.6466, y: 0.5066),
                CGPoint(x: 0.2537, y: 0.6588),
                CGPoint(x: 0.2783, y: 0.3642),
                CGPoint(x: 0.3068, y: 0.0),
                CGPoint(x: 0.5656, y: 0.3293)
            ],
            lines: [(0, 1), (0, 3), (1, 2), (2, 6), (3, 4), (4, 5), (4, 6), (5, 6)]
        ),
        "CrB": Constellation(
            id: "CrB",
            name: "Corona Borealis",
            meaning: "A crown crafted by Hephaestus",
            stars: [
                CGPoint(x: 0.0, y: 0.3373),
                CGPoint(x: 0.103, y: 0.7476),
                CGPoint(x: 0.3454, y: 0.8629),
                CGPoint(x: 0.5556, y: 0.8328),
                CGPoint(x: 0.8011, y: 0.7731),
                CGPoint(x: 1.0, y: 0.441),
                CGPoint(x: 0.8406, y: 0.1371)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
        ),
        "Dra": Constellation(
            id: "Dra",
            name: "Draco",
            meaning: "The dragon guarding the golden apples",
            stars: [
                CGPoint(x: 1.0, y: 0.4884),
                CGPoint(x: 0.8207, y: 0.5735),
                CGPoint(x: 0.6828, y: 0.4878),
                CGPoint(x: 0.465, y: 0.3491),
                CGPoint(x: 0.2239, y: 0.0984),
                CGPoint(x: 0.0, y: 0.1756),
                CGPoint(x: 0.2391, y: 0.6898),
                CGPoint(x: 0.351, y: 0.7665),
                CGPoint(x: 0.3572, y: 0.8817),
                CGPoint(x: 0.1933, y: 0.9016)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (6, 9), (7, 8), (8, 9)]
        ),
        "Peg": Constellation(
            id: "Peg",
            name: "Pegasus",
            meaning: "The horse whose hoof opened the Muses’ spring",
            stars: [
                CGPoint(x: 0.7813, y: 0.1312),
                CGPoint(x: 0.5918, y: 0.2257),
                CGPoint(x: 0.4697, y: 0.2839),
                CGPoint(x: 0.0778, y: 0.2193),
                CGPoint(x: 0.0, y: 0.6032),
                CGPoint(x: 0.4578, y: 0.6272),
                CGPoint(x: 0.5742, y: 0.7086),
                CGPoint(x: 0.8248, y: 0.8688),
                CGPoint(x: 1.0, y: 0.7587)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (2, 5), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8)]
        ),
        "Cyg": Constellation(
            id: "Cyg",
            name: "Cygnus",
            meaning: "Orpheus, changed into a swan",
            stars: [
                CGPoint(x: 0.9158, y: 0.0),
                CGPoint(x: 0.8485, y: 0.077),
                CGPoint(x: 0.772, y: 0.3438),
                CGPoint(x: 0.5121, y: 0.5327),
                CGPoint(x: 0.7068, y: 0.732),
                CGPoint(x: 0.9371, y: 1.0),
                CGPoint(x: 0.3094, y: 0.7607),
                CGPoint(x: 0.0629, y: 0.8802),
                CGPoint(x: 0.3906, y: 0.3304)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (3, 4), (3, 6), (3, 8), (4, 5), (6, 7)]
        ),
        "Per": Constellation(
            id: "Per",
            name: "Perseus",
            meaning: "The hero who faced Medusa through a reflection",
            stars: [
                CGPoint(x: 0.2047, y: 0.8779),
                CGPoint(x: 0.2624, y: 0.5357),
                CGPoint(x: 0.4719, y: 0.4104),
                CGPoint(x: 0.6701, y: 0.1682),
                CGPoint(x: 0.7953, y: 0.0),
                CGPoint(x: 0.7774, y: 0.2112),
                CGPoint(x: 0.6344, y: 0.4269),
                CGPoint(x: 0.637, y: 0.7406),
                CGPoint(x: 0.6597, y: 1.0)
            ],
            lines: [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8)]
        ),
        "UMi": Constellation(
            id: "UMi",
            name: "Ursa Minor",
            meaning: "Polaris, the star that guides travelers",
            stars: [
                CGPoint(x: 0.6246, y: 1.0),
                CGPoint(x: 0.6969, y: 0.8398),
                CGPoint(x: 0.4715, y: 0.6983),
                CGPoint(x: 0.3785, y: 0.819),
                CGPoint(x: 0.316, y: 0.4746),
                CGPoint(x: 0.3031, y: 0.2186),
                CGPoint(x: 0.3393, y: 0.0)
            ],
            lines: [(0, 1), (0, 3), (1, 2), (2, 3), (2, 4), (4, 5), (5, 6)]
        )
    ]
}
