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
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                WordMarkView()
               
                AuthHeader(heading: "CREATE ACCOUNT", subheading: "START YOUR JOURNEY")
                
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
            .padding(.vertical, 12)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingNextScreen) {
            IdentityCreationView()
        }
    }
}

#Preview {
    CreateAccountView()
}
