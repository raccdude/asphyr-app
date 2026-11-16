//
//  AccountLoadingView.swift
//  Asphyr
//

import SwiftUI

/// Shown instead of Splash when a signed-in account can't load. The flame sits where
/// Splash and the launch screen draw it, so nothing jumps.
struct AccountLoadingView: View {
    let errorMessage: String
    let onRetry: () -> Void
    let onLogOut: () -> Void

    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            // The words sit under the flame, which stays where Splash draws it
            VStack(spacing: 28) {
                Image("asphyrPrismMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 77, height: 98)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    // Reassures first: a dropped connection never loses progress
                    Text("Every step you’ve taken is safe.")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(Color.asphyrTextPrimary)

                    Text(errorMessage)
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(Color.asphyrTextSecondary)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)
            }
            // Centers on the flame rather than the whole stack
            .alignmentGuide(VerticalAlignment.center) { $0[.top] + 49 }
            .offset(y: -95)
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                PrimaryButton(title: "TRY AGAIN", action: onRetry)

                Button("Log out", action: onLogOut)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
}

#Preview("No connection", traits: .dark) {
    AccountLoadingView(errorMessage: AccountError.noConnection.message, onRetry: {}, onLogOut: {})
}
