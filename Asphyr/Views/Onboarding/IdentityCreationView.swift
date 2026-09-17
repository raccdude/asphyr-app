//
//  IdentityCreationView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct IdentityCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColor: Color = .red // change
    @State private var username: String = ""
    @State private var isShowingNextScreen: Bool = false
    @State private var selectedAspirationID: UUID? = nil
    
    let colors: [Color] = [.asphyrAccentPrimary, .blue, .yellow, .orange, .teal, .purple]
    
    let aspirations = [
        Aspiration(iconName: "laptopcomputer.and.iphone", title: "Game Developer", description: "Build interactive games"),
        Aspiration(iconName: "wrench.and.screwdriver", title: "Mechanical Engineer", description: "Design & build systems"),
        Aspiration(iconName: "brain.head.profile", title: "Psychologist", description: "Understand the mind"),
        Aspiration(iconName: "stethoscope", title: "Doctor", description: "Heal & care for others"),
        Aspiration(iconName: "book.pages.fill", title: "Writer", description: "Craft stories & ideas"),
        Aspiration(iconName: "sparkles", title: "Something else", description: "Define your own path")
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 145, maximum: 165), spacing: 12),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.asphyrBackground
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        Button {
                            dismiss() // Executes back navigation
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.asphyrTextPrimary)
                                .frame(width: 44, height: 44, alignment: .leading)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("STEP 1 OF 2")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.asphyrTextSecondary)
                                .tracking(1)
                            
                            HStack(spacing: 4) {
                                RectangleView(height: 2, width: 45, color: Color.asphyrAccentPrimary)
                                RectangleView(height: 2, width: 45)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            Text("BUILD YOUR IDENTITY") // ADD SPACE GROTESK
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.asphyrAccentPrimary)
                            
                            Spacer()
                            
                            Character()
                            
                            VStack(spacing: 8) {
                                //Text("SHIRT COLOR")
                                //.font(.system(size: 14, weight: .medium))
                                //.foregroundStyle(.white)
                                
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        ForEach(colors, id: \.self) { color in
                                            ColoredDots(
                                                color: color,
                                                isSelected: selectedColor == color)
                                            .scaleEffect(selectedColor == color ? 1.2 : 1.0)
                                            .opacity(selectedColor == color ? 1.0 : 0.6)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    selectedColor = color
                                                }
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .frame(height: 44)
                            }
                            
                            // 24 px space
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("WHAT SHOULD WE CALL YOU?")
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                
                                AsphyrTextField(placeholder: "Enter your name", text: $username)
                                
                                // 24 px space
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("WHO DO YOU ASPIRE TO BE?")
                                        .font(.system(size: 14))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white)
                                    
                                    LazyVGrid(columns: columns, spacing: 12) {
                                        ForEach(aspirations) { item in
                                            AspirationCard(
                                                aspiration: item,
                                                isSelected: selectedAspirationID == item.id
                                            )
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    selectedAspirationID = item.id
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                
                                PrimaryButton(name: "CONTINUE") {
                                    if username != "" && selectedAspirationID != nil {
                                        isShowingNextScreen = true
                                    }
                                }
                            }
                            
                        }
                        .padding(.horizontal, 20)
                    }
                    .navigationDestination(isPresented: $isShowingNextScreen) {
                        ArchetypeSelectionView()
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
        
#Preview {
    IdentityCreationView()
}
