//
//  AuthHeader.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

/// The title and subtitle under `AuthTopBar`.
struct AuthHeader: View {
    let heading: String
    let subheading: String

    var body: some View {
        VStack(spacing: 8) {
            Text(heading)
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(subheading)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 36)
    }
}
