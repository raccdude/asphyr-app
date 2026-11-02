//
//  ArchetypeCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct ArchetypeCard: View {
    let archetype: Archetype
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(archetype.iconName)
                .foregroundStyle(isSelected ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(archetype.title)
                    .font(AppTypography.subheading)
                    .foregroundStyle(Color.asphyrTextPrimary)

                Text(archetype.description)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 18)
        // Narrow, so the descriptions stay on one line on smaller iPhones
        .padding(.trailing, 6)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 75)
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
