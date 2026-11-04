//
//  SocialSignInRow.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The Apple and Google sign-in row from Figma "05 — Hi-Fi v2".
/// Display only until real sign-in exists.
struct SocialSignInRow: View {
    var body: some View {
        HStack(spacing: 12) {
            option(name: "Apple") {
                Image("iconAppleLogo")
                    .foregroundStyle(Color.asphyrTextPrimary)
            }

            option(name: "Google") {
                Image("googleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
        }
    }

    private func option(name: String, @ViewBuilder logo: () -> some View) -> some View {
        HStack(spacing: 10) {
            logo()
                .accessibilityHidden(true)

            Text(name)
                .font(AppTypography.bodySemiBold)
                .foregroundStyle(Color.asphyrTextPrimary)
        }
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }
}

#Preview {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        SocialSignInRow()
            .padding(.horizontal, 20)
    }
}
