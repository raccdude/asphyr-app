//
//  PasswordChecklist.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The live password requirements shown under the password field.
struct PasswordChecklist: View {
    let password: String

    static func hasEnoughCharacters(_ password: String) -> Bool {
        password.count >= 8
    }

    static func containsNumber(_ password: String) -> Bool {
        password.contains(where: \.isNumber)
    }

    static func isValid(_ password: String) -> Bool {
        hasEnoughCharacters(password) && containsNumber(password)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            row("At least 8 characters", isMet: Self.hasEnoughCharacters(password))
            row("Contains a number", isMet: Self.containsNumber(password))
        }
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(_ title: String, isMet: Bool) -> some View {
        HStack(spacing: 8) {
            Image("iconCheck")
                .foregroundStyle(isMet ? Color.asphyrBackground : Color.asphyrTextSecondary)
                .frame(width: 16, height: 16)
                .background(isMet ? Color.asphyrAccentPrimary : Color.asphyrSurfaceElevated, in: Circle())
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.captionMedium)
                .foregroundStyle(isMet ? Color.asphyrTextPrimary : Color.asphyrTextSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(isMet ? "Met" : "Not met")
    }
}

#Preview {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        PasswordChecklist(password: "abc123")
            .padding(.horizontal, 20)
    }
}
