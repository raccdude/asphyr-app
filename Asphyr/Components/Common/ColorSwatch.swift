//
//  ColorSwatch.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct ColorSwatch: View {
    let color: Color
    let isSelected: Bool

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 32, height: 32)
            .overlay {
                // Keeps pale and dark colors visible on any background
                Circle()
                    .strokeBorder(Color.asphyrTextSecondary.opacity(0.6), lineWidth: 1)

                if isSelected {
                    Circle()
                        .stroke(Color.asphyrTextPrimary, lineWidth: 2)
                        .padding(-4)
                }
            }
    }
}
