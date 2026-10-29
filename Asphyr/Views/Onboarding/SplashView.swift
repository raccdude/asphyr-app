//
//  SplashView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showLogo: Bool = false
    @State private var isPulsing: Bool = false
    @State private var navigateToWelcome: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // BACKGROUND + SHEEN
                Color.asphyrBackground

                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.07), location: 0),
                        .init(color: .white.opacity(0), location: 0.55)
                    ],
                    startPoint: UnitPoint(x: -0.23, y: 0.41),
                    endPoint: UnitPoint(x: 1.23, y: 0.59)
                )

                // FLAME + ASPHYR
                VStack(spacing: 21) {
                    Image("asphyrPrismMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 77, height: 98)
                        .background(alignment: .top) {
                            // Green halo behind the flame
                            Ellipse()
                                .fill(Color.asphyrAccentPrimary.opacity(0.16))
                                .frame(width: 113, height: 105)
                                .blur(radius: 40)
                        }

                    Text("ASPHYR")
                        .font(AppTypography.display)
                        .tracking(1.92)
                        .foregroundStyle(Color.asphyrAccentPrimary)
                }
                .offset(y: -50)
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(showLogo || reduceMotion ? 1 : 0.96)

                // TAP ANYWHERE TO BEGIN
                VStack {
                    Spacer()

                    Text("TAP ANYWHERE TO BEGIN")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .opacity(
                            showLogo
                            ? (isPulsing ? 0.45 : 1.0)
                            : 0
                        )
                        .animation(
                            .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                        .padding(.bottom, 62)
                }
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                navigateToWelcome = true
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Asphyr")
            .accessibilityHint("Tap anywhere to begin")
            .accessibilityAddTraits(.isButton)
            .onAppear {
                // Fade in flame + ASPHYR
                withAnimation(.easeOut(duration: 0.8)) {
                    showLogo = true
                }

                // Start tap-text pulse after logo appears
                guard !reduceMotion else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isPulsing = true
                }
            }
            .navigationDestination(isPresented: $navigateToWelcome) {
                WelcomeView()
            }
        }
    }
}

#Preview {
    SplashView()
}
