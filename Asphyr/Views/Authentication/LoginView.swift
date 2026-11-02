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

    @Environment(AppRouter.self) private var router

    var body: some View {
        AuthScreen {
            VStack(spacing: 16) {
                AuthHeader(heading: "WELCOME BACK", subheading: "CONTINUE YOUR JOURNEY")
                
                Spacer()
                
                VStack(spacing: 22) {
                    AsphyrTextField(placeholder: "Email", text: $email)
                    AsphyrSecureField(placeholder: "Password", text: $password)   
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        router.push(.recover)
                    } label: {
                        Text("Forgot password?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.asphyrTextPrimary)
                    }
                }
                  
                Spacer()
                
                PrimaryButton(name: "LOG IN") {
                    if !email.isEmpty && !password.isEmpty {
                        router.push(.home)
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
                    
                    Button {
                        router.switchTo(.createAccount)
                    } label: {
                        Text("CREATE ACCOUNT")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.asphyrAccentPrimary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(AppRouter())
}
