//
//  CreateAccount.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

struct CreateAccountView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
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
                        .padding(.top, 10)
                    
                    VStack(spacing: 16) {
                        Text("CREATE ACCOUNT")
                            .font(.system(size: 24, weight: .bold)) // change
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .padding(.top, 40)
                        
                        Text("START YOUR JOURNEY")
                            .font(.system(size: 16, weight: .medium)) // change
                            .foregroundStyle(Color.asphyrTextSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 22) {
                        AsphyrTextField(placeholder: "Email", text: $email)
                        AsphyrSecureField(placeholder: "Password", text: $password)
                        AsphyrSecureField(placeholder: "Confirm password", text: $passwordConfirmation)
                    }
                    
                    Spacer()
                    
                    PrimaryButton(name: "CREATE ACCOUNT") {
                        if !email.isEmpty && !password.isEmpty && password == passwordConfirmation {
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
                        Text("Already have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.asphyrTextSecondary)
                        
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("LOG IN")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.asphyrAccentPrimary)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(isPresented: $isShowingNextScreen) {
                LoginView()
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
