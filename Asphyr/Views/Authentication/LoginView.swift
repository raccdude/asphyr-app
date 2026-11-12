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
    @State private var errorMessage: String?
    @State private var isBusy = false

    private var showsError: Bool {
        errorMessage != nil
    }

    @FocusState private var focus: Field?

    var body: some View {
        AuthScreen {
            content
        }
        .animation(.easeInOut(duration: 0.2), value: showsError)
        .onChange(of: email) {
            errorMessage = nil
        }
        .onChange(of: password) {
            errorMessage = nil
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
                .characterLimit(TextLimits.email, text: $email)
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
                .characterLimit(TextLimits.password, text: $password)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onSubmit(submit)
            }
            .padding(.top, 36)

            if let errorMessage {
                FieldErrorRow(message: errorMessage)
                    .padding(.top, 8)
            }

            forgotPasswordButton
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 12)

            PrimaryButton(title: "LOG IN", isBusy: isBusy, action: submit)
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

    private func submit() {
        focus = nil

        guard email.isValidEmail, !password.isEmpty else {
            errorMessage = AccountError.invalidCredentials.message
            return
        }

        isBusy = true
        Task {
            defer { isBusy = false }

            do {
                try await AccountService.logIn(email: email, password: password)
                try await ProfileService.load(into: profile)
                router.showAccount(isOnboarded: profile.isComplete)
            } catch {
                errorMessage = (error as? AccountError ?? .unknown).message
            }
        }
    }
}

#Preview(traits: .dark) {
    NavigationStack {
        LoginView()
    }
    .environment(AppRouter())
        .environment(OnboardingProfile())
}
