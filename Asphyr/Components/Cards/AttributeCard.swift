//
//  AttributeCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct AttributeCard: View {
    let attribute: UserAttribute

    var body: some View {
        HStack(spacing: 12) {
            Image(attribute.iconName)
                .foregroundStyle(Color.asphyrAccentPrimary)
                .frame(width: 34, height: 34)
                .background(Color.asphyrAccentPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(attribute.name)
                    .font(AppTypography.captionRegular)
                    .foregroundStyle(Color.asphyrTextSecondary)

                Text(attribute.value)
                    .font(AppTypography.screenTitle)
                    .foregroundStyle(Color.asphyrTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 75)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }
}
