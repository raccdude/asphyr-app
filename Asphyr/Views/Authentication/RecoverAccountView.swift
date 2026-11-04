//
//  RecoverAccountView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct RecoverAccountView: View {
    private enum Field: Hashable {
        case email
    }

    @Environment(AppRouter.self) private var router

    @State private var email: String = ""
    @State private var showsError = false
    @State private var sendError: String?
    @State private var isBusy = false

    @FocusState private var focus: Field?

    private var spiritMood: SpiritView.Mood {
        if showsError { return .surprised }
        return focus == .email ? .focused : .wave
    }

    var body: some View {
        AuthScreen {
            content
        }
        .animation(.easeInOut(duration: 0.2), value: showsError)
        .onChange(of: focus) { oldValue, _ in
            // Only checks what the user has typed, so an empty field stays calm
            if oldValue == .email {
                showsError = !email.isEmpty && !email.isValidEmail
            }
        }
        .onChange(of: email) {
            showsError = false
            sendError = nil
        }
    }

    private var content: some View {
        ScrollViewReader { proxy in
            fields
                .onChange(of: focus) { _, newValue in
                    guard newValue == .email else { return }
                    // The field sits low enough for the keyboard to cover it,
                    // so bring it up once the keyboard has opened
                    Task {
                        try? await Task.sleep(for: .milliseconds(350))
                        withAnimation(.easeInOut(duration: 0.25)) {
                            proxy.scrollTo(Field.email, anchor: UnitPoint(x: 0.5, y: 0.85))
                        }
                    }
                }
        }
    }

    private var fields: some View {
        VStack(spacing: 0) {
            AuthHeader(heading: "ACCOUNT RECOVERY", subheading: "RESET YOUR PASSWORD")

            SpiritMessage(mood: spiritMood, message: "“We’ll help you get\nback on track.”")
                .padding(.top, 20)

            Text("Enter the email associated\nwith your ASPHYR account.")
                .font(AppTypography.body)
                .foregroundStyle(Color.asphyrTextPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .padding(.top, 40)

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
            .submitLabel(.send)
            .onSubmit(submit)
            .id(Field.email)
            .padding(.top, 18)

            if showsError {
                FieldErrorRow(message: "Enter a valid email address.")
                    .padding(.top, 8)
            }

            if let sendError {
                FieldErrorRow(message: sendError)
                    .padding(.top, 8)
            }

            Spacer(minLength: 24)

            PrimaryButton(title: "SEND RESET LINK", isBusy: isBusy, action: submit)
        }
        .padding(.horizontal, 20)
        // Tapping empty space dismisses the keyboard
        .contentShape(Rectangle())
        .onTapGesture {
            focus = nil
        }
    }

    private func submit() {
        focus = nil

        guard email.isValidEmail else {
            showsError = true
            return
        }

        isBusy = true
        Task {
            defer { isBusy = false }

            do {
                try await AccountService.sendPasswordReset(email: email)
                router.push(.recoverySuccess(email: email))
            } catch {
                sendError = (error as? AccountError ?? .unknown).message
            }
        }
    }
}


#Preview(traits: .dark) {
    NavigationStack {
        RecoverAccountView()
    }
    .environment(AppRouter())
}
