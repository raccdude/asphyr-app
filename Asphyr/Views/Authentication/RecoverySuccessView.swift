//
//  RecoverySuccessView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct RecoverySuccessView: View {
    let email: String

    @Environment(AppRouter.self) private var router

    @State private var resendCount = 0
    @State private var resendSecondsLeft = 0
    @State private var showsToast = false

    var body: some View {
        AuthScreen {
            content
        }
        .overlay(alignment: .top) {
            if showsToast {
                AsphyrToast(icon: "iconMailSmall", message: "Reset link sent again to \(email)")
                    .padding(.horizontal, 20)
                    .padding(.top, -4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture {
                        showsToast = false
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showsToast)
        .task(id: resendCount) {
            await runResendCooldown()
        }
        .task(id: resendCount) {
            await hideToastAfterDelay()
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            AuthHeader(heading: "RECOVERY SUCCESS", subheading: "CHECK YOUR EMAIL")

            SpiritMessage(mood: .cheer, message: "“You’re almost back\non your journey.”")
                .padding(.top, 20)

            VStack(spacing: 1) {
                Text("We sent a password reset link to")
                    .font(AppTypography.body)
                    .foregroundStyle(Color.asphyrTextSecondary)

                Text(email)
                    .font(AppTypography.bodySemiBold)
                    .foregroundStyle(Color.asphyrTextPrimary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 40)

            Text("Check your inbox and follow\nthe instructions to continue.")
                .font(AppTypography.body)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .padding(.top, 14)

            Spacer(minLength: 24)

            PrimaryButton(title: "BACK TO LOGIN") {
                router.popToLogin()
            }

            resendRow
                .padding(.top, 16)
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var resendRow: some View {
        if resendSecondsLeft > 0 {
            HStack(spacing: 6) {
                Image("iconClock")
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .accessibilityHidden(true)

                Text("You can resend again in \(formattedSecondsLeft)")
                    .font(AppTypography.bodySecondary)
                    .monospacedDigit()
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .multilineTextAlignment(.center)
            }
        } else {
            AuthSwitchPrompt(prompt: "Didn’t get it?", actionTitle: "Resend email", action: resend)
        }
    }

    private var formattedSecondsLeft: String {
        String(format: "%d:%02d", resendSecondsLeft / 60, resendSecondsLeft % 60)
    }

    /// Email is mocked until a backend exists, so nothing is actually sent.
    private func resend() {
        resendSecondsLeft = 30
        showsToast = true
        resendCount += 1
    }

    private func runResendCooldown() async {
        while resendSecondsLeft > 0 {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }
            resendSecondsLeft -= 1
        }
    }

    private func hideToastAfterDelay() async {
        guard showsToast else { return }

        do {
            try await Task.sleep(for: .seconds(3))
        } catch {
            return
        }
        showsToast = false
    }
}


#Preview(traits: .dark) {
    NavigationStack {
        RecoverySuccessView(email: "lou@gmail.com")
    }
    .environment(AppRouter())
}
