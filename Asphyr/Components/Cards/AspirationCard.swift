//
//  AspirationCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct AspirationCard: View {
    let aspiration: Aspiration
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image(aspiration.iconName)
                .foregroundStyle(isSelected ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
                .accessibilityHidden(true)

            Text(aspiration.title)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            Text(aspiration.description)
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 108)
        .background {
            // The shadow sits on the shape so it doesn't also glow behind the text
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.asphyrSurfaceElevated : Color.asphyrSurface)
                .shadow(color: isSelected ? Color.asphyrAccentPrimary : .clear, radius: 1, x: 0, y: 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isSelected ? Color.asphyrSurfaceElevated : Color.asphyrBorder, lineWidth: 1)
        }
    }
}
