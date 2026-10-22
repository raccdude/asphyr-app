//
//  LoginView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingNextScreen: Bool = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.asphyrBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    WordMarkView() {
                        dismiss()
                    }
                    
                    AuthHeader(heading: "WELCOME BACK", subheading: "CONTINUE YOUR JOURNEY")
                    
                    Spacer()
                    
                    VStack(spacing: 22) {
                        AsphyrTextField(placeholder: "Email", text: $email)
                        AsphyrSecureField(placeholder: "Password", text: $password)   
                    }
                    
                    HStack {
                        Spacer()
                        
                        NavigationLink {
                            RecoverAccountView()
                        } label: {
                            Text("Forgot password?")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.asphyrTextPrimary)
                        }
                    }
                      
                    Spacer()
                    
                    PrimaryButton(name: "LOG IN") {
                        if !email.isEmpty && !password.isEmpty {
                            isShowingNextScreen = true
                        }
                    }
                    
                    HStack {
                        RectangleView(height: 1)
                        
                        Text("OR")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.asphyrTextSecondary)
                        
                        RectangleView(height: 1)
                        
                    }

                    HStack(spacing: 12) {
                        BrandCard(brandLogo: "apple.logo", brandName: "Apple", isSystemSymbol: true)
                        BrandCard(brandLogo: "googleLogo", brandName: "Google")
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Don't have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.asphyrTextSecondary)
                        
                        NavigationLink {
                            CreateAccountView()
                        } label: {
                            Text("CREATE ACCOUNT")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.asphyrAccentPrimary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingNextScreen) {
                HomeView()
            }
           
        }
    }
}

#Preview {
    LoginView()
}
