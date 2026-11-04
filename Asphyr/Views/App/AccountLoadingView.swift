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

            Image("asphyrPrismMark")
                .resizable()
                .scaledToFit()
                .frame(width: 77, height: 98)
                .offset(y: -95)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Text(errorMessage)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .multilineTextAlignment(.center)

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
