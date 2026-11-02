//
//  FieldErrorRow.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The error message shown under an invalid field.
struct FieldErrorRow: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image("iconAlert")
                .accessibilityHidden(true)

            Text(message)
                .font(AppTypography.captionMedium)
        }
        .foregroundStyle(Color.asphyrError)
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        FieldErrorRow(message: "Enter a valid email address.")
            .padding(.horizontal, 20)
    }
}
