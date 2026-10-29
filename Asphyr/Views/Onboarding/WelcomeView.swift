//
//  WelcomeView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isShowingNextScreen = false

    var body: some View {
        // No NavigationStack here: Welcome is pushed onto SplashView's stack,
        // so Create Account and Log In are pushed onto that same stack.
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // WORDMARK
                Text("ASPHYR")
                    .font(AppTypography.wordMark)
                    .tracking(1.44)
                    .foregroundStyle(Color.asphyrAccentPrimary)

                Spacer(minLength: 24)

                // CHARACTER + MESSAGE + CTA
                VStack(spacing: 0) {
                    Image("characterSilhouette")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 134, height: 134)
                        .accessibilityHidden(true)

                    Text("YOUR JOURNEY STARTS\nWITH ONE STEP.")
                        .font(AppTypography.screenTitle)
                        .foregroundStyle(Color.asphyrTextPrimary)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, 44)

                    Text("You don’t have to become that person today.\nJust take one step toward becoming them.")
                        .font(AppTypography.body)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(1)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .padding(.top, 14)

                    PrimaryButtonV2(title: "BEGIN JOURNEY") {
                        isShowingNextScreen = true
                    }
                    .padding(.top, 37)
                }
                // Sits slightly above centre, as in Figma
                .padding(.bottom, 22)

                Spacer(minLength: 24)

                // LOG IN PROMPT (one line)
                HStack(spacing: 7.5) {
                    Text("Already have an account?")
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(Color.asphyrTextSecondary)

                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("LOG IN")
                            .font(AppTypography.bodySecondarySemiBold)
                            .foregroundStyle(Color.asphyrAccentPrimary)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
        .navigationDestination(isPresented: $isShowingNextScreen) {
            CreateAccountView()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
