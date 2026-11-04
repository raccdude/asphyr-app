//
//  SplashView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AppRouter.self) private var router

    @State private var showLogo: Bool = false
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            // BACKGROUND + SHEEN
            Color.asphyrBackground

            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.07), location: 0),
                    .init(color: .white.opacity(0), location: 0.5)
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
                            .opacity(showLogo ? 1 : 0)
                            .animation(.easeOut(duration: 0.4), value: showLogo)
                    }
                    // The launch screen shows this same flame in this same spot, so it starts
                    // visible and pops from there. The name follows.
                    .keyframeAnimator(initialValue: CGFloat(1), trigger: showLogo) { flame, scale in
                        flame.scaleEffect(scale)
                    } keyframes: { _ in
                        KeyframeTrack(\.self) {
                            SpringKeyframe(reduceMotion ? 1 : 1.12, duration: 0.2, spring: .snappy)
                            SpringKeyframe(1, duration: 0.4, spring: .bouncy)
                        }
                    }

                Text("ASPHYR")
                    .font(AppTypography.display)
                    .tracking(1.92)
                    .foregroundStyle(Color.asphyrAccentPrimary)
                    .scaleEffect(showLogo || reduceMotion ? 1 : 0.85)
                    .opacity(showLogo ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15), value: showLogo)
            }
            .offset(y: -64)

            // TAP ANYWHERE TO BEGIN
            VStack {
                Spacer()

                Text("TAP ANYWHERE TO BEGIN")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(
                        showLogo
                        ? (isPulsing ? 0.45 : 1.0)
                        : 0
                    )
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: showLogo)
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
            router.push(.welcome)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Asphyr")
        .accessibilityHint("Tap anywhere to begin")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            showLogo = true

            // Start tap-text pulse after logo appears
            guard !reduceMotion else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isPulsing = true
            }
        }
    }
}

#Preview(traits: .dark) {
    NavigationStack {
        SplashView()
    }
    .environment(AppRouter())
}
