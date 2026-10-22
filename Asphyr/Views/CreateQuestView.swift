//
//  CreateQuestView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct CreateQuestView: View {
    @State private var questTitle: String = ""
    @State private var isShowingNextScreen: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()
            
            VStack() {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(Color.asphyrTextPrimary)
                    }
                    
                    Spacer()
                    
                    Text("CREATE QUEST")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.asphyrTextPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 22, height: 22)
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("What will you accomplish?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.asphyrTextPrimary)
                    
                    AsphyrTextField(placeholder: "Enter quest title", text: $questTitle)
                    
                    
                }
                
                PrimaryButton(name: "CREATE QUEST") {
                    if !questTitle.isEmpty {
                        isShowingNextScreen = true
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingNextScreen) {
                HomeView()
            }
        }
    }
}

#Preview {
    CreateQuestView()
}
