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

    private enum PasswordSide: Hashable {
        case hidden, shown
    }

    /// Which of the two password fields has the keyboard.
    @FocusState private var focusedSide: PasswordSide?

    /// iOS clears a password field on the first key after it takes the keyboard back,
    /// so the text from before hiding is kept to restore it.
    @State private var textBeforeHiding: String?

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
                if isSecure {
                    passwordFields
                } else {
                    TextField("", text: $text, prompt: promptText)
                        .focused(focus, equals: field)
                }
            }
            .font(AppTypography.body)
            .foregroundStyle(Color.asphyrTextPrimary)
            .tint(Color.asphyrAccentPrimary)

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

    /// Both fields stay on screen, one hidden, and the eye moves typing straight from
    /// one to the other. Removing the focused field would close the keyboard.
    private var passwordFields: some View {
        ZStack {
            SecureField("", text: $text, prompt: promptText)
                .focused($focusedSide, equals: .hidden)
                .opacity(isRevealed ? 0 : 1)
                .allowsHitTesting(!isRevealed)
                .accessibilityHidden(isRevealed)

            // A shown password is still a password: no suggestions or capitals
            TextField("", text: $text, prompt: promptText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focusedSide, equals: .shown)
                .opacity(isRevealed ? 1 : 0)
                .allowsHitTesting(isRevealed)
                .accessibilityHidden(!isRevealed)
        }
        // Lets the form see and set focus here, for the border and Return-to-next-field
        .focused(focus, equals: field)
        // Keeps the form's focus and this field's own focus in step
        .onChange(of: focus.wrappedValue) { _, newValue in
            if newValue == field {
                if focusedSide != visibleSide { focusedSide = visibleSide }
            } else if focusedSide != nil {
                focusedSide = nil
            }
        }
        .onChange(of: focusedSide) { _, newValue in
            if newValue != nil {
                if focus.wrappedValue != field { focus.wrappedValue = field }
            } else if focus.wrappedValue == field {
                focus.wrappedValue = nil
            }
        }
        .onAppear {
            if focus.wrappedValue == field { focusedSide = visibleSide }
        }
        // Undoes the clear: keeps what was typed and applies the new key to it
        .onChange(of: text) { oldValue, newValue in
            guard let before = textBeforeHiding else { return }
            textBeforeHiding = nil
            if newValue.isEmpty, oldValue == before {
                text = String(before.dropLast())
            } else if !newValue.hasPrefix(before), oldValue == before {
                text = before + newValue
            }
        }
    }

    private var visibleSide: PasswordSide {
        isRevealed ? .shown : .hidden
    }

    private var revealButton: some View {
        Button {
            isRevealed.toggle()
            if focusedSide != nil {
                focusedSide = visibleSide
            }
            textBeforeHiding = (!isRevealed && focusedSide != nil && !text.isEmpty) ? text : nil
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
