//
//  AsphyrToast.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// A short confirmation shown over the top of a screen.
struct AsphyrToast: View {
    let icon: String
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .foregroundStyle(Color.asphyrAccentPrimary)
                .frame(width: 32, height: 32)
                .background(Color.asphyrAccentPrimary.opacity(0.15), in: Circle())
                .accessibilityHidden(true)

            Text(message)
                .font(AppTypography.bodySemiBold)
                .foregroundStyle(Color.asphyrTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 66)
        .background(Color.asphyrSurfaceElevated, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.45), radius: 7.5, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .dark) {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        AsphyrToast(icon: "iconMailSmall", message: "Reset link sent again to lou@gmail.com")
            .padding(.horizontal, 20)
    }
}
