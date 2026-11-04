//
//  SetNewPasswordView.swift
//  Asphyr
//

import SwiftUI

/// Opened by the link in a password reset email, which also signs the user in.
struct SetNewPasswordView: View {
    private enum Field: Hashable {
        case password, confirmPassword
    }

    @Environment(AppRouter.self) private var router
    @Environment(OnboardingProfile.self) private var profile

    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var showsMismatchError = false
    @State private var errorMessage: String?
    @State private var isBusy = false

    @FocusState private var focus: Field?

    var body: some View {
        AuthScreen(showsBackButton: false) {
            VStack(spacing: 0) {
                AuthHeader(heading: "NEW PASSWORD", subheading: "CHOOSE A NEW PASSWORD")

                VStack(spacing: 12) {
                    VStack(spacing: 10) {
                        AsphyrInputField(
                            placeholder: "New Password",
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

                        PasswordChecklist(password: password)
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

                if let errorMessage {
                    FieldErrorRow(message: errorMessage)
                        .padding(.top, 8)
                }

                PrimaryButton(title: "SAVE PASSWORD", isBusy: isBusy, action: submit)
                    .padding(.top, 28)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            // Tapping empty space dismisses the keyboard
            .contentShape(Rectangle())
            .onTapGesture {
                focus = nil
            }
        }
        .onChange(of: password) {
            errorMessage = nil
            showsMismatchError = false
        }
        .onChange(of: passwordConfirmation) {
            errorMessage = nil
            showsMismatchError = false
        }
    }

    private func submit() {
        focus = nil
        showsMismatchError = password != passwordConfirmation

        guard PasswordChecklist.isValid(password), !showsMismatchError else { return }

        isBusy = true
        Task {
            defer { isBusy = false }

            do {
                try await AccountService.updatePassword(password)
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
        SetNewPasswordView()
    }
    .environment(AppRouter())
    .environment(OnboardingProfile())
}
