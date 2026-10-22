//
//  SplashView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct SplashView: View {
    @State private var showLogo: Bool = false
    @State private var isPulsing: Bool = false
    @State private var navigateToWelcome: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.asphyrBackground
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    // FLAME + ASPHYR
                    VStack(spacing: 12) {
                        ZStack {
                            Image("asphyrLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                
                                Circle()
                                    .fill(Color.asphyrAccentPrimary)
                                    .frame(width: 100, height: 100)
                                    .blur(radius: 40)
                                    .opacity(0.1)
                        }
                        .offset(y: -10)
                    
                        Text("ASPHYR")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(Color.asphyrAccentPrimary)
                            .tracking(6)
                            .offset(y: -40)
                    }
                    .opacity(showLogo ? 1 : 0)

                    Spacer()

                    Text("TAP ANYWHERE TO BEGIN")
                        .font(.system(size: 12, weight: .medium))
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
                        .padding(.bottom, 40)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                navigateToWelcome = true
            }
            .onAppear {
                // Fade in flame + ASPHYR
                withAnimation(.easeOut(duration: 0.8)) {
                    showLogo = true
                }
                
                // Start tap-text pulse after logo appears
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


