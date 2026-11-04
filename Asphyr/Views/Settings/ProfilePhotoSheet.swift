//
//  ProfilePhotoSheet.swift
//  Asphyr
//

import SwiftUI

struct ProfilePhotoSheet: View {
    enum Choice {
        case camera
        case library
    }

    /// Closes this sheet first, as iOS can only present one at a time.
    let onChoose: (Choice) -> Void

    @Environment(OnboardingProfile.self) private var profile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SettingsSheetHeader(title: "PROFILE PHOTO", closeTitle: "Cancel") {
                dismiss()
            }

            Text("Shown on your profile and in Settings. Your character still represents you everywhere else.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            VStack(spacing: 0) {
                if ImagePicker.isCameraAvailable {
                    Button {
                        onChoose(.camera)
                        dismiss()
                    } label: {
                        SettingsRow(icon: "iconSettingsCamera", title: "Take photo")
                    }
                    .buttonStyle(.plain)

                    SettingsRowDivider()
                }

                Button {
                    onChoose(.library)
                    dismiss()
                } label: {
                    SettingsRow(
                        icon: "iconSettingsImage",
                        title: "Choose from library",
                        subtitle: "Opens the iOS photo picker"
                    )
                }
                .buttonStyle(.plain)

                SettingsRowDivider()

                Button {
                    profile.photoData = nil
                    dismiss()
                } label: {
                    SettingsRow(
                        icon: "iconSettingsPerson",
                        title: "Use my character",
                        subtitle: profile.photoData == nil ? "Current" : nil
                    )
                }
                .buttonStyle(.plain)
            }
            .settingsCard()
            .padding(.top, 16)

            if profile.photoData != nil {
                Button {
                    profile.photoData = nil
                    dismiss()
                } label: {
                    SettingsRow(
                        icon: "iconSettingsTrash",
                        title: "Remove photo",
                        tint: .asphyrError,
                        titleColor: .asphyrError,
                        tileColor: Color.asphyrError.opacity(0.15)
                    )
                }
                .buttonStyle(.plain)
                .settingsCard()
                .padding(.top, 12)
            }

            Spacer(minLength: 16)

            SettingsCancelButton {
                dismiss()
            }
        }
        .padding(.horizontal, 19)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .settingsSheet(height: 520)
    }
}
