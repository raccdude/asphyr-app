//
//  RecoverySuccessView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct RecoverySuccessView: View {
    @State private var isShowingNextScreen: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.asphyrBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 16) { // make header
                    Text("ASPHYR")
                        .font(.system(size: 24, weight: .bold)) // change
                        .foregroundStyle(Color.asphyrAccentPrimary)
                    
                    VStack(spacing: 16) {
                        Text("ACCOUNT RECOVERY")
                            .font(.system(size: 24, weight: .bold)) // change
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .padding(.top, 40)
                        
                        Text("CHECK YOUR EMAIL")
                            .font(.system(size: 16, weight: .medium)) // change
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 8) {
                            Image("asphyrLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text("You're almost back\non your journey.")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.asphyrTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 40)
                        }
                        
                        Text("We sent a password reset link\nto your email address.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Check your inbox and follow\nthe instructions to continue.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)

                        PrimaryButton(name: "BACK TO LOGIN") {
                            isShowingNextScreen = true
                        }
                            
                        Spacer()
                        
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationDestination(isPresented: $isShowingNextScreen) {
            LoginView()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RecoverySuccessView()
}
