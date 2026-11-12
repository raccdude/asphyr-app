//
//  SocialSignInRow.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The Apple and Google sign-in row from Figma "05 — Hi-Fi v2". Signing in also
/// creates the account the first time, so it works the same on Login and Create
/// Account. See `Backend/SocialSignIn.swift`.
struct SocialSignInRow: View {
    /// Shown by the screen, under its own fields.
    @Binding var errorMessage: String?

    @Environment(AppRouter.self) private var router
    @Environment(OnboardingProfile.self) private var profile

    @State private var isBusy = false

    var body: some View {
        HStack(spacing: 12) {
            option(.apple, name: "Apple") {
                Image("iconAppleLogo")
                    .foregroundStyle(Color.asphyrTextPrimary)
            }

            option(.google, name: "Google") {
                Image("googleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
        }
        .opacity(isBusy ? 0.6 : 1)
        .animation(.easeInOut(duration: 0.2), value: isBusy)
    }

    private func option(_ provider: SocialProvider, name: String, @ViewBuilder logo: () -> some View) -> some View {
        Button {
            signIn(with: provider)
        } label: {
            HStack(spacing: 10) {
                logo()
                    .accessibilityHidden(true)

                Text(name)
                    .font(AppTypography.bodySemiBold)
                    .foregroundStyle(Color.asphyrTextPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.asphyrBorder, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Continue with \(name)")
    }

    private func signIn(with provider: SocialProvider) {
        guard !isBusy else { return }

        isBusy = true
        errorMessage = nil
        Task {
            defer { isBusy = false }

            do {
                guard try await SocialSignIn.signIn(with: provider) else { return }
                try await ProfileService.load(into: profile)
                router.showAccount(isOnboarded: profile.isComplete)
            } catch {
                errorMessage = (error as? AccountError ?? .unknown).message
            }
        }
    }
}

#Preview(traits: .dark) {
    ZStack {
        Color.asphyrBackground.ignoresSafeArea()
        SocialSignInRow(errorMessage: .constant(nil))
            .padding(.horizontal, 20)
    }
    .environment(AppRouter())
    .environment(OnboardingProfile())
}
