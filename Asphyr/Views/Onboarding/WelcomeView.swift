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
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Text("ASPHYR")
                        .font(.system(size: 24, weight: .bold)) // add app typography
                        .foregroundStyle(Color.asphyrAccentPrimary)
                        .tracking(4)
                    
                    Spacer()
                    
                    Character()
     
                    Text("YOUR JOURNEY STARTS \nWITH ONE STEP.")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.asphyrTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("You don't have to become that person today. \nJust take one step toward becoming them.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .multilineTextAlignment(.center)
                 
                    PrimaryButton(name: "BEGIN JOURNEY") {
                        isShowingNextScreen = true
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
        }
        .navigationDestination(isPresented: $isShowingNextScreen) {
            CreateAccountView()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeView()
}
