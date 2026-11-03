//
//  ResetProgressSheet.swift
//  Asphyr
//

import SwiftUI

struct ResetProgressSheet: View {
    let onReset: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Image("iconSettingsWarning")
                .foregroundStyle(Color.asphyrError)
                .frame(width: 66, height: 66)
                .background(Color.asphyrError.opacity(0.15), in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.asphyrError.opacity(0.5), lineWidth: 1)
                }
                .accessibilityHidden(true)

            Text("Reset all progress?")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .padding(.top, 16)

            Text("This can’t be undone.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 8)

            VStack(spacing: 0) {
                row("iconSettingsBolt", "XP and levels")
                SettingsRowDivider()
                row("iconSettingsTarget", "Attributes")
                SettingsRowDivider()
                row("iconSettingsScroll", "Quest history")
                SettingsRowDivider()
                row("iconBadgeStar", "Cloaks and badges")
            }
            .settingsCard()
            .padding(.top, 20)

            Text("Your account, name and identity stay the same.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            Spacer(minLength: 16)

            Button {
                onReset()
                dismiss()
            } label: {
                Text("RESET PROGRESS")
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
        .settingsSheet(height: 700)
    }

    private func row(_ icon: String, _ title: String) -> some View {
        SettingsRow(
            icon: icon,
            title: title,
            tint: .asphyrError,
            tileColor: Color.asphyrError.opacity(0.15)
        )
    }
}
