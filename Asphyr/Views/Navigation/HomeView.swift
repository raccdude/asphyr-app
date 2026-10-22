//
//  HomeView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingNextScreen: Bool = false
    
    let userAttributes: [UserAttribute] = [
        UserAttribute(name: "KNOWLEDGE", value: "10"),
        UserAttribute(name: "DISCIPLINE", value: "10"),
        UserAttribute(name: "CREATIVITY", value: "10"),
        UserAttribute(name: "PROBLEM SOLVING", value: "10")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.asphyrBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack(alignment: .center) {
                            Text("ASPHYR")
                                .font(.system(size: 26, weight: .black))
                                .foregroundStyle(Color.asphyrAccentPrimary)
                                .tracking(4)
                            
                            Spacer()
                        
                            Button {
                                isShowingNextScreen = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color.asphyrTextPrimary)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("GOOD MORNING") // PLACEHOLDER; WILL CHANGE BASED ON TIME
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.asphyrTextPrimary)
                                    .tracking(1)
                                
                                Text("Lou") // PLACEHOLDER
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(Color.asphyrTextPrimary)
                            }
                            Spacer()
                        }
                        
                        Spacer()
    
                        Character()
                        
                        Spacer()
        
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
                        
                        Spacer()
         
                        // PROGRESS INDICATOR
                        VStack(spacing: 4) {
                            HStack {
                                Text("0 / 500 XP") // PLACEHOLDER
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.asphyrTextPrimary)
                                
                                Spacer()
                                
                                Text("500 XP TO LEVEL 2") // PLACEHOLDER
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.asphyrTextPrimary)
                            }
                            
                           XPBar()
                        }
                        .padding(.horizontal, 40)
                                        
                        // SECTIONS
                        VStack(spacing: 12) {
                            // QUEST SECTION
                            SectionDivider(sectionTitle: "TODAY'S QUEST")
        
                            // REUSABLE QUEST CARD
                            QuestCard()
                            
                            // ATTRIBUTE SECTION
                           SectionDivider(sectionTitle: "ATTRIBUTES")
                            
                            // ATTRIBUTE LAYOUT
                            LazyVGrid(columns: columns) {
                                ForEach(userAttributes, id: \.name) {
                                    item in AttributeCard(attribute: item)
                                }
                            }
                        }
                       
                    }
                    .padding(.horizontal, 20)
                      
                }
            
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingNextScreen) {
                SettingsView()
            }
        }
    }
}

#Preview {
    HomeView()
}
