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
            Image(systemName: archetype.iconName)
                .font(.system(size: 20)) // CHANGE SIZE
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isSelected ? Color.asphyrAccentPrimary : .white)
                .frame(width: 40, height: 40)
              
            VStack(alignment: .leading, spacing: 4) {
                Text(archetype.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Text(archetype.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white)

            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.asphyrSurfaceElevated : Color.asphyrSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: isSelected ? Color.asphyrAccentPrimary : .clear,
            radius: isSelected ? 2 : 0, x: 0, y: 1)
    }
}
