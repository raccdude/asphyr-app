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
        
        VStack(spacing: 6) {
            Image(systemName: aspiration.iconName)
                .font(.system(size: 20)) // CHANGE SIZE
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isSelected ? Color.asphyrAccentPrimary: Color.asphyrTextPrimary) // change to Color.primaryAccent
            
            Text(aspiration.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.asphyrTextPrimary) // change to primary text
                .multilineTextAlignment(.center)

            Text(aspiration.description)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
        }
        .padding(20)
        .frame(width: 155, height: 110)
        .background(isSelected ? Color.asphyrSurfaceElevated : Color.asphyrSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 1)
        )
        .shadow(
            color: isSelected ? Color.asphyrAccentPrimary : .clear,
            radius: isSelected ? 2 : 0, x: 0, y: 1)
        
    }
}
