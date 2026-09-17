//
//  RecoverAccountView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct RecoverAccountView: View {
    @State private var email: String = ""
    
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
                        
                        Text("RESET YOUR PASSWORD")
                            .font(.system(size: 16, weight: .medium)) // change
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 8) {
                            Image("asphyrLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text("We'll help you get\nback on track.")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.asphyrTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 40)
                        }
                        
                        Text("Enter the email associated\nwith your ASPHYR account.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                        
                        AsphyrTextField(placeholder: "Email", text: $email)
                        
                        PrimaryButton(name: "SEND RESET LINK") {
                            if !email.isEmpty {
                                isShowingNextScreen = true
                            }
                        }
                        
                        Spacer()
                        
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(isPresented: $isShowingNextScreen) {
                RecoverySuccessView()
            }
        }
    }
}

#Preview {
    RecoverAccountView()
}
