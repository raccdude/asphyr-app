//
//  LoginView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

struct LoginView: View {
    private enum Field: Hashable {
        case email, password
    }

    @Environment(AppRouter.self) private var router
    @Environment(OnboardingProfile.self) private var profile

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showsError = false

    @FocusState private var focus: Field?

    var body: some View {
        AuthScreen {
            content
        }
        .animation(.easeInOut(duration: 0.2), value: showsError)
        .onChange(of: email) {
            showsError = false
        }
        .onChange(of: password) {
            showsError = false
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            AuthHeader(heading: "WELCOME BACK", subheading: "CONTINUE YOUR JOURNEY")

            // FIELDS
            VStack(spacing: 12) {
                AsphyrInputField(
                    placeholder: "Email",
                    icon: "iconMail",
                    text: $email,
                    focus: $focus,
                    field: .email,
                    hasError: showsError
                )
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .onSubmit { focus = .password }

                AsphyrInputField(
                    placeholder: "Password",
                    icon: "iconLock",
                    text: $password,
                    focus: $focus,
                    field: .password,
                    isSecure: true,
                    hasError: showsError
                )
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onSubmit(submit)
            }
            .padding(.top, 36)

            if showsError {
                FieldErrorRow(message: "Incorrect email or password. Try again.")
                    .padding(.top, 8)
            }

            forgotPasswordButton
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 12)

            PrimaryButton(title: "LOG IN", action: submit)
                .padding(.top, 24)

            OrDivider()
                .padding(.top, 22)

            SocialSignInRow()
                .padding(.top, 22)

            Spacer(minLength: 24)

            AuthSwitchPrompt(prompt: "Don’t have an account?", actionTitle: "CREATE ACCOUNT") {
                router.switchTo(.createAccount)
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

    private var forgotPasswordButton: some View {
        Button {
            router.push(.recover)
        } label: {
            Text("Forgot password?")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                // Grows the tap area to about 44 pt without moving the layout
                .padding(.vertical, 14)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
                .padding(.vertical, -14)
                .padding(.horizontal, -8)
        }
    }

    /// Authentication is mocked until a backend exists, so this only checks the
    /// format. Any well-formed email with a password logs in.
    private func submit() {
        focus = nil

        if email.isValidEmail && !password.isEmpty {
            profile.email = email
            router.enterApp()
        } else {
            showsError = true
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(AppRouter())
        .environment(OnboardingProfile())
}
