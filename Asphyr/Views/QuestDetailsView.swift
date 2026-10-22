//
//  QuestDetailsView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct QuestDetailsView: View {
    
    @State private var isShowingNextScreen: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(Color.asphyrTextPrimary)
                    }
                    
                    Spacer()
                    
                    Text("DAILY QUEST")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.asphyrTextPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 22, height: 22)
                }
                .padding(.bottom, 40)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        VStack(spacing: 12) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.asphyrTextPrimary)
                                .padding(.bottom, 4)
                            
                            Text("BUILD A SMALL MECHANIC")
                                .font(.system(size: 16, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            Text("Turn a simple idea into a working feature.")
                                .font(.system(size: 14, weight: .regular))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.asphyrTextSecondary)
                            
                            QuestStatus(status: .available)
                            
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        RectangleView()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("OBJECTIVE")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            Text("Implement one small gameplay mechanic in your current project.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.asphyrTextSecondary)
                        }
 
                        RectangleView()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DETAILS")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            HStack {
                                Text("DURATION")
                                    .font(.caption2)
                                    .foregroundStyle(Color.asphyrTextSecondary)
                                    
                                Spacer()
                                Text("30 MIN")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundStyle(Color.asphyrTextPrimary)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 20)
                            .background(Color.asphyrSurface)
                            .clipShape(Capsule())
     
                            HStack {
                                Text("DIFFICULTY")
                                    .font(.caption2)
                                    .foregroundStyle(Color.asphyrTextSecondary)
                                Spacer()
                                Text("MODERATE")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundStyle(Color.asphyrTextPrimary)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 20)
                            .background(Color.asphyrSurface)
                            .clipShape(Capsule())
                        }
                        
                        RectangleView()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("REWARDS")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            HStack {
                                Text("EXPERIENCE")
                                    .font(.caption2)
                                    .foregroundStyle(Color.asphyrTextSecondary)
                                Spacer()
                                Text("+100")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundStyle(Color.asphyrWarning)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 20)
                            .background(Color.asphyrSurface)
                            .clipShape(Capsule())
                            
                            HStack {
                                Text("CREATIVITY")
                                    .font(.caption2)
                                    .foregroundStyle(Color.asphyrTextSecondary)
                                Spacer()
                                Text("+5")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundStyle(Color.asphyrWarning)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 20)
                            .background(Color.asphyrSurface)
                            .clipShape(Capsule())
                        }
                    }
                }
                
                PrimaryButton(name: "ACCEPT QUEST") {
                    isShowingNextScreen = true
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingNextScreen) {
            HomeView() // change
        }
    }
}

#Preview {
    QuestDetailsView()
}
