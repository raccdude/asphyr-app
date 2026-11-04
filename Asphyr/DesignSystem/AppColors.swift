//
//  AppColors.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

extension Color {
    static let asphyrBackground = Color("BackgroundPrimary")
    static let asphyrSurface = Color("SurfacePrimary")
    static let asphyrSurfaceElevated = Color("SurfaceElevated")

    static let asphyrTextPrimary = Color("TextPrimary")
    static let asphyrTextSecondary = Color("TextSecondary")

    static let asphyrBorder = Color("BorderPrimary")

    static let asphyrAccentPrimary = Color("AccentPrimary")
    static let asphyrAccentSecondary = Color("AccentSecondary")

    /// The primary button's gradient, also used by bars and the comet.
    static let asphyrGradientLight = Color(red: 125 / 255, green: 255 / 255, blue: 155 / 255)  // #7DFF9B
    static let asphyrGradientDeep = Color(red: 0 / 255, green: 230 / 255, blue: 59 / 255)      // #00E63B

    static let asphyrWarning = Color("StatusWarning")
    static let asphyrError = Color("StatusError")
}
