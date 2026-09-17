//
//  HomeView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 4) {
                        Text("ASPHYR")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.asphyrAccentPrimary)
                            .tracking(4)
                            .padding(.bottom, 40)
                        
                        HStack {
                            Text("GOOD MORNING") // PLACEHOLDER; WILL CHANGE BASED ON TIME
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.asphyrTextPrimary)

                            Spacer()
                        }
                            
                        HStack {
                            Text("Lou") // PLACEHOLDER
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            Spacer()
                        }
                        .padding(.bottom, 60)
                        
                        // AVATAR
                        
                        Character()
                            .padding(.bottom, 20)
        
                        VStack(spacing: 8) {
                            Text("The Strategist".uppercased())// PLACEHOLDER
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            Text("Game Developer") // PLACEHOLDER
                                .font(.system(size: 16))
                                .fontWeight(.regular)
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            Text("LEVEL 1") // PLACEHOLDER
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.vertical, 2)
                                .padding(.horizontal, 12)
                                .background(Color.asphyrAccentPrimary, in: .capsule)
                        }
         
                        // PROGRESS TRACKER
                        HStack {
                            Text("0 / 500 XP") // PLACEHOLDER
                                .font(.system(size: 12))
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            Spacer()
                            
                            Text("500 XP TO LEVEL 2") // PLACEHOLDER
                                .font(.system(size: 12))
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                        }
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .padding(.bottom, 20)
                        
                        
                        // QUEST SECTION
                        VStack(spacing: 6) {
                            HStack(spacing: 12) {
                                SectionHeader(title: "TODAY'S QUEST")
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            
                            // REUSABLE QUEST CARD
                            QuestCard()
                        }
                        
                        VStack(spacing: 6) {
                            // ATTRIBUTE SECTION
                            HStack(spacing: 12) {
                                SectionHeader(title: "ATTRIBUTES")
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            
                            // ATTRIBUTE LAYOUT
                        }
                        
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
