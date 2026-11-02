//
//  CreateAccount.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

struct CreateAccountView: View {
    private enum Field: Hashable {
        case email, password, confirmPassword
    }

    @Environment(AppRouter.self) private var router

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""

    @State private var showsEmailError = false
    @State private var showsMismatchError = false
    @State private var showsPasswordRules = false

    @FocusState private var focus: Field?

    private var isEmailValid: Bool {
        email.wholeMatch(of: /[^@\s]+@[^@\s]+\.[^@\s]+/) != nil
    }

    private var doPasswordsMatch: Bool {
        password == passwordConfirmation
    }

    var body: some View {
        AuthScreen {
            content
        }
        .animation(.easeInOut(duration: 0.2), value: showsEmailError)
        .animation(.easeInOut(duration: 0.2), value: showsMismatchError)
        .animation(.easeInOut(duration: 0.2), value: isPasswordChecklistVisible)
        .onChange(of: focus) { oldValue, _ in
            validateOnLeaving(oldValue)
        }
        .onChange(of: email) {
            showsEmailError = false
        }
        .onChange(of: password) {
            showsMismatchError = false
        }
        .onChange(of: passwordConfirmation) {
            showsMismatchError = false
        }
    }

    private var isPasswordChecklistVisible: Bool {
        focus == .password || showsPasswordRules
    }

    private var content: some View {
        VStack(spacing: 0) {
            AuthHeader(heading: "CREATE ACCOUNT", subheading: "START YOUR JOURNEY")

            // FIELDS
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    AsphyrInputField(
                        placeholder: "Email",
                        icon: "iconMail",
                        text: $email,
                        focus: $focus,
                        field: .email,
                        hasError: showsEmailError
                    )
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .onSubmit { focus = .password }

                    if showsEmailError {
                        FieldErrorRow(message: "Enter a valid email address.")
                    }
                }

                VStack(spacing: 10) {
                    AsphyrInputField(
                        placeholder: "Password",
                        icon: "iconLock",
                        text: $password,
                        focus: $focus,
                        field: .password,
                        isSecure: true
                    )
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .onSubmit { focus = .confirmPassword }

                    if isPasswordChecklistVisible {
                        PasswordChecklist(password: password)
                    }
                }

                VStack(spacing: 8) {
                    AsphyrInputField(
                        placeholder: "Confirm Password",
                        icon: "iconLock",
                        text: $passwordConfirmation,
                        focus: $focus,
                        field: .confirmPassword,
                        isSecure: true,
                        hasError: showsMismatchError
                    )
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .onSubmit(submit)

                    if showsMismatchError {
                        FieldErrorRow(message: "Passwords don’t match.")
                    }
                }
            }
            .padding(.top, 36)

            PrimaryButtonV2(title: "CREATE ACCOUNT", action: submit)
                .padding(.top, 28)

            OrDivider()
                .padding(.top, 22)

            SocialSignInRow()
                .padding(.top, 22)

            Spacer(minLength: 24)

            AuthSwitchPrompt(prompt: "Already have an account?", actionTitle: "LOG IN") {
                router.switchTo(.login)
            }
            .padding(.bottom, 6)
        }
        .padding(.horizontal, 20)
        // Tapping empty space dismisses the keyboard
        .contentShape(Rectangle())
        .onTapGesture {
            focus = nil
        }
    }

    /// Only checks what the user has typed, so an untouched field stays calm.
    private func validateOnLeaving(_ field: Field?) {
        switch field {
        case .email:
            showsEmailError = !email.isEmpty && !isEmailValid
        case .password:
            showsPasswordRules = !password.isEmpty && !PasswordChecklist.isValid(password)
            showsMismatchError = !passwordConfirmation.isEmpty && !doPasswordsMatch
        case .confirmPassword:
            showsMismatchError = !passwordConfirmation.isEmpty && !doPasswordsMatch
        case nil:
            break
        }
    }

    private func submit() {
        focus = nil
        showsEmailError = !isEmailValid
        showsPasswordRules = !PasswordChecklist.isValid(password)
        showsMismatchError = !doPasswordsMatch

        if isEmailValid && PasswordChecklist.isValid(password) && doPasswordsMatch {
            router.push(.identity)
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
    .environment(AppRouter())
}
