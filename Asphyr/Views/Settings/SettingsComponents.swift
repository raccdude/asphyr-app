//
//  SettingsComponents.swift
//  Asphyr
//

import SwiftUI

/// A row in a Settings card, with an icon tile and optional trailing content.
struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    var subtitle: String?
    var tint: Color = .asphyrTextPrimary
    var titleColor: Color = .asphyrTextPrimary
    var tileColor: Color = .asphyrSurfaceElevated
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tileColor, in: RoundedRectangle(cornerRadius: 9))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(titleColor)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }
}

extension SettingsRow where Trailing == EmptyView {
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        tint: Color = .asphyrTextPrimary,
        titleColor: Color = .asphyrTextPrimary,
        tileColor: Color = .asphyrSurfaceElevated
    ) {
        self.init(icon: icon, title: title, subtitle: subtitle, tint: tint, titleColor: titleColor, tileColor: tileColor) {
            EmptyView()
        }
    }
}

/// A row's "value and chevron", as on Notifications and Appearance.
struct SettingsDisclosure: View {
    var value: String?

    var body: some View {
        HStack(spacing: 10) {
            if let value {
                Text(value)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }

            Image("iconChevronRight")
                .foregroundStyle(Color.asphyrTextSecondary)
                .accessibilityHidden(true)
        }
    }
}

struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
            .labelsHidden()
            .tint(Color.asphyrAccentPrimary)
    }
}

struct SettingsRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.asphyrBorder)
            .frame(height: 1)
            .padding(.leading, 60)
    }
}

/// The title and leading button along the top of a Settings sheet.
struct SettingsSheetHeader: View {
    let title: String
    let closeTitle: String
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(AppTypography.subheading)
                .foregroundStyle(Color.asphyrTextPrimary)
                .accessibilityAddTraits(.isHeader)

            HStack {
                Button(closeTitle, action: onClose)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .frame(minHeight: 44)

                Spacer()
            }
        }
    }
}

/// The screen title in a pushed Settings screen's bar.
struct SettingsNavigationTitle: ToolbarContent {
    let title: String

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(AppTypography.subheading)
                .foregroundStyle(Color.asphyrTextPrimary)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

/// The outlined Cancel button on Settings sheets.
struct SettingsCancelButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Cancel")
                .font(AppTypography.bodySemiBold)
                .foregroundStyle(Color.asphyrTextPrimary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.asphyrBorder, lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func settingsCard(cornerRadius: CGFloat = 18) -> some View {
        background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.asphyrBorder, lineWidth: 1)
            }
    }

    /// Opens at the designed height. On a shorter screen, or with larger text, the sheet
    /// is capped by iOS, so its content scrolls instead of being cut off at the bottom.
    func settingsSheet(height: CGFloat) -> some View {
        ViewThatFits(in: .vertical) {
            self
            ScrollView {
                self
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .presentationDetents([.height(height)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.asphyrSurface)
            .presentationCornerRadius(28)
    }

    /// Shows a message over the top of the screen for 3 seconds.
    func settingsToast(_ message: Binding<String?>, icon: String = "iconAlert") -> some View {
        modifier(SettingsToastModifier(message: message, icon: icon))
    }
}

private struct SettingsToastModifier: ViewModifier {
    @Binding var message: String?
    let icon: String

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    AsphyrToast(icon: icon, message: message)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: message)
            .task(id: message) {
                guard message != nil else { return }

                do {
                    try await Task.sleep(for: .seconds(3))
                    message = nil
                } catch {
                    // A newer message restarted the delay
                }
            }
    }
}

/// The user's photo, or the character's face cropped into a rounded square.
struct ProfileAvatar: View {
    let size: CGFloat
    let cornerRadius: CGFloat
    /// The character's size and how far it's lowered to frame the face, centered
    /// across the crop.
    let characterSize: CGFloat
    let characterOffsetY: CGFloat

    @Environment(OnboardingProfile.self) private var profile

    var body: some View {
        // An overlay, so the larger character doesn't change the frame's size
        Color.asphyrBackground
            .frame(width: size, height: size)
            .overlay {
                if let data = profile.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                } else {
                    CharacterArt(color: profile.color, archetype: profile.archetype, cloak: profile.cloak, showsGlow: false)
                        .frame(width: characterSize, height: characterSize)
                        .offset(y: characterOffsetY)
                }
            }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}
