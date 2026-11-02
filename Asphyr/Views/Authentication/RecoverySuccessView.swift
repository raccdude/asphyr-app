//
//  RecoverySuccessView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct RecoverySuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                WordMarkView() {
                    dismiss()
                }
                
                AuthHeader(heading: "RECOVERY SUCCESS", subheading: "CHECK YOUR EMAIL")
                
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
                    .font(AppTypography.body)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Check your inbox and follow\nthe instructions to continue.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                PrimaryButton(name: "BACK TO LOGIN") {
                    router.popToLogin()
                }
                    
                Spacer()
                
            }
            .padding(.horizontal, 20)
        }
        
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }

}


#Preview {
    NavigationStack {
        RecoverySuccessView()
    }
    .environment(AppRouter())
}
