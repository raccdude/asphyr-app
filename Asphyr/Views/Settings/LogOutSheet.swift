//
//  LogOutSheet.swift
//  Asphyr
//

import SwiftUI

/// Nothing is saved to an account yet, so logging out loses everything.
struct LogOutSheet: View {
    let onLogOut: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Image("iconSettingsLogOut")
                .resizable()
                .frame(width: 26, height: 26)
                .foregroundStyle(Color.asphyrError)
                .frame(width: 66, height: 66)
                .background(Color.asphyrError.opacity(0.15), in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.asphyrError.opacity(0.5), lineWidth: 1)
                }
                .accessibilityHidden(true)

            Text("Log out?")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .padding(.top, 16)

            Text("Progress isn’t saved to an account yet, so logging out will erase it.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Spacer(minLength: 16)

            Button {
                dismiss()
                onLogOut()
            } label: {
                Text("LOG OUT")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(Color(red: 26 / 255, green: 5 / 255, blue: 5 / 255))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.asphyrError, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressableButtonStyle())

            SettingsCancelButton {
                dismiss()
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 19)
        .padding(.top, 41)
        .padding(.bottom, 24)
        .settingsSheet(height: 400)
    }
}
