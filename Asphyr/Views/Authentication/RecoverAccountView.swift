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
                    
                    AuthHeader(heading: "ACCOUNT RECOVERY", subheading: "RESET YOUR PASSWORD")
                    
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
                    
                    Spacer()
                    
                    PrimaryButton(name: "SEND RESET LINK") {
                        if !email.isEmpty {
                            isShowingNextScreen = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingNextScreen) {
                RecoverySuccessView()
            }
        }
    }
}


#Preview {
    RecoverAccountView()
}
