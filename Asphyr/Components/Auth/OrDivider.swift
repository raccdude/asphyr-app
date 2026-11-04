//
//  OrDivider.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack(spacing: 14) {
            RectangleView(height: 1)

            Text("OR")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)

            RectangleView(height: 1)
        }
    }
}

#Preview(traits: .dark) {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        OrDivider()
            .padding(.horizontal, 20)
    }
}
