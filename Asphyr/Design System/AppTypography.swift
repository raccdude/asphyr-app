//
//  AppTypography.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

enum AppTypography {
    static let display = Font.custom(
        "SpaceGrotesk-Bold",
        size: 32
    )

    static let screenTitle = Font.custom(
        "SpaceGrotesk-SemiBold",
        size: 24,
        relativeTo: .largeTitle
    ).weight(.black)

    static let sectionTitle = Font.custom(
        "SpaceGrotesk-SemiBold",
        size: 20
    )

    static let subheading = Font.custom(
        "SpaceGrotesk-Medium",
        size: 16,
    )
    
    static let bodyMedium = Font.custom(
        "Inter24pt-Medium",
        size: 16
    )
    
    static let body = Font.custom(
        "Inter24pt-Regular",
        size: 16
    )

    static let bodySecondary = Font.custom(
        "Inter24pt-Regular",
        size: 14
    )

    static let captionMedium = Font.custom(
        "Inter24pt-Medium",
        size: 12
    )
    
    static let captionRegular = Font.custom(
        "Inter24pt-Regular",
        size: 10
    )


}

