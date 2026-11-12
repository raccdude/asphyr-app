//
//  SocialSignInRow.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// Google sign-in, under the email form on Login and Create Account. Signing in also
/// creates the account the first time, so it works the same on both. Apple sign-in was
/// removed on 12 Nov 2026 at the developer's request. See `Backend/SocialSignIn.swift`.
struct SocialSignInRow: View {
    @Environment(AppRouter.self) private var router
    @Environment(OnboardingProfile.self) private var profile

    @State private var isBusy = false
    /// Shown under the button, so the screen's own fields don't turn red.
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            option(.google, name: "Continue with Google") {
                Image("googleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .opacity(isBusy ? 0.6 : 1)

            if let errorMessage {
                FieldErrorRow(message: errorMessage)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isBusy)
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
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
        .accessibilityLabel(name)
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
        SocialSignInRow()
            .padding(.horizontal, 20)
    }
    .environment(AppRouter())
    .environment(OnboardingProfile())
}
