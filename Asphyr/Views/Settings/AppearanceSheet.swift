//
//  AppearanceSheet.swift
//  Asphyr
//

import SwiftUI

struct AppearanceSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var selection: AppSettings.Appearance = .dark

    var body: some View {
        VStack(spacing: 0) {
            SettingsSheetHeader(title: "APPEARANCE", closeTitle: "Close") {
                dismiss()
            }

            HStack(spacing: 12) {
                ForEach(AppSettings.Appearance.allCases) { appearance in
                    option(appearance)
                }
            }
            .padding(.top, 24)

            Text("ASPHYR is designed dark-first. Light mode keeps the same layout with brighter surfaces.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Spacer(minLength: 16)

            PrimaryButton(title: "DONE") {
                settings.appearance = selection
                dismiss()
            }
        }
        .padding(.horizontal, 19)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .onAppear {
            selection = settings.appearance
        }
        .settingsSheet(height: 470)
    }

    private func option(_ appearance: AppSettings.Appearance) -> some View {
        let isSelected = selection == appearance

        return Button {
            selection = appearance
        } label: {
            VStack(spacing: 12) {
                preview(appearance)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .frame(height: 132)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 2)
                    }

                Text(appearance.rawValue)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextPrimary)

                Circle()
                    .strokeBorder(isSelected ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(Color.asphyrAccentPrimary)
                                .frame(width: 8, height: 8)
                        }
                    }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(appearance.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // These show each mode, so they keep their colors in either appearance
    private static let darkBackground = Color(red: 11 / 255, green: 13 / 255, blue: 19 / 255)    // #0B0D13
    private static let lightBackground = Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255) // #F3F4F6

    @ViewBuilder
    private func preview(_ appearance: AppSettings.Appearance) -> some View {
        switch appearance {
        case .dark:
            miniScreen(
                background: Self.darkBackground,
                accent: Color(red: 0, green: 1, blue: 64 / 255),                  // #00FF40
                card: Color(red: 30 / 255, green: 32 / 255, blue: 39 / 255)       // #1E2027
            )
        case .light:
            miniScreen(
                background: Self.lightBackground,
                accent: Color(red: 0, green: 201 / 255, blue: 52 / 255),          // #00C934
                card: Color(red: 217 / 255, green: 220 / 255, blue: 227 / 255)    // #D9DCE3
            )
        case .system:
            HStack(spacing: 0) {
                Self.darkBackground
                Self.lightBackground
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func miniScreen(background: Color, accent: Color, card: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Capsule()
                .fill(accent)
                .frame(width: 32, height: 6)
                .padding(.bottom, 0)

            RoundedRectangle(cornerRadius: 6)
                .fill(card)
                .frame(height: 24)

            RoundedRectangle(cornerRadius: 6)
                .fill(card)
                .frame(height: 24)

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(background, in: RoundedRectangle(cornerRadius: 12))
    }
}
