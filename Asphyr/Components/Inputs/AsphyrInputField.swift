//
//  AsphyrInputField.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The input field from Figma "05 — Hi-Fi v2".
struct AsphyrInputField<Field: Hashable>: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    let focus: FocusState<Field?>.Binding
    let field: Field
    var isSecure: Bool = false
    var hasError: Bool = false
    var fill: Color = .asphyrSurface

    @State private var isRevealed = false

    private var isFocused: Bool { focus.wrappedValue == field }

    private var accentColor: Color {
        if hasError { return .asphyrError }
        return isFocused ? .asphyrAccentPrimary : .asphyrTextSecondary
    }

    private var borderColor: Color {
        if hasError { return .asphyrError }
        return isFocused ? .asphyrAccentPrimary : .asphyrBorder
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .foregroundStyle(accentColor)
                .accessibilityHidden(true)
                .allowsHitTesting(false)

            Group {
                if isSecure && !isRevealed {
                    SecureField("", text: $text, prompt: promptText)
                } else if isSecure {
                    // A shown password is still a password: no suggestions or capitals
                    TextField("", text: $text, prompt: promptText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    TextField("", text: $text, prompt: promptText)
                }
            }
            .font(AppTypography.body)
            .foregroundStyle(Color.asphyrTextPrimary)
            .tint(Color.asphyrAccentPrimary)
            .focused(focus, equals: field)

            if isSecure {
                revealButton
            }
        }
        .padding(.leading, 17)
        .padding(.trailing, isSecure ? 5 : 17)
        .frame(minHeight: 52)
        // Behind the text field, so it only catches taps on the icon and
        // padding. On top, it also fires for taps on the text, and iOS reads
        // that as a second tap and selects the whole word.
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(fill)
                .onTapGesture {
                    focus.wrappedValue = field
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(borderColor, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var promptText: Text {
        Text(placeholder).foregroundStyle(Color.asphyrTextSecondary)
    }

    private var revealButton: some View {
        Button {
            let wasFocused = isFocused
            isRevealed.toggle()
            // Swapping the field type drops focus, so hand it back
            if wasFocused {
                Task { focus.wrappedValue = field }
            }
        } label: {
            Group {
                if isRevealed {
                    // Figma has no icon for the revealed state
                    Image(systemName: "eye")
                        .font(.system(size: 14))
                } else {
                    Image("iconEyeOff")
                }
            }
            .foregroundStyle(Color.asphyrTextSecondary)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
    }
}

#Preview(traits: .dark) {
    @Previewable @FocusState var focus: Int?
    @Previewable @State var email = ""
    @Previewable @State var password = "secret"

    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        VStack(spacing: 12) {
            AsphyrInputField(placeholder: "Email", icon: "iconMail", text: $email, focus: $focus, field: 0)
            AsphyrInputField(placeholder: "Password", icon: "iconLock", text: $password, focus: $focus, field: 1, isSecure: true)
            AsphyrInputField(placeholder: "Email", icon: "iconMail", text: $password, focus: $focus, field: 2, hasError: true)
        }
        .padding(.horizontal, 20)
    }
}
