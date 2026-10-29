//
//  RewardView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct RewardView: View {
    
    @State private var isShowingNextScreen: Bool = false
    
    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                Text("QUEST COMPLETE")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.asphyrAccentPrimary)
                
                Text("BUILD A SMALL MECHANIC")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.asphyrTextPrimary)
                
                Image("asphyrLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("+100 XP")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.asphyrWarning)
                
                Text("+5 CREATIVITY")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.asphyrWarning)
                
                Text("+2 DISCIPLINE")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.asphyrWarning)
                
                VStack(spacing: 4) {
                    HStack {
                        Text("EXPERIENCE")
                            .font(.caption)
                            .foregroundStyle(Color.asphyrTextSecondary)
                        
                        Spacer()
                        
                        Text("0 / 700 XP")
                            .font(.caption)
                            .foregroundStyle(Color.asphyrTextSecondary)
                    }
                    
                    XPBar()
                }
                
                Text("LEVEL UP")
                    .font(.subheadline)
                    .foregroundStyle(Color.asphyrTextPrimary)
                
                Text("2")
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(Color.asphyrAccentPrimary)
                
                Text("NEW REWARD UNLOCKED")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Color.asphyrWarning)
                
                Spacer()
                
                PrimaryButton(name: "CONTINUE") {
                    isShowingNextScreen = true
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

#Preview {
    RewardView()
}
