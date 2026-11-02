//
//  RecoverAccountView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct RecoverAccountView: View {
    @State private var email: String = ""

    @Environment(AppRouter.self) private var router

    var body: some View {
        AuthScreen {
            VStack(spacing: 16) {
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
                        router.push(.recoverySuccess)
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
        RecoverAccountView()
    }
    .environment(AppRouter())
}
