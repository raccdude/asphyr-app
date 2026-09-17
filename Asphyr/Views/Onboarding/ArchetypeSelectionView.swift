//
//  ArchetypeSelectionView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct ArchetypeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingNextScreen = false
    @State private var selectedArchetypeID: UUID? = nil
    @State private var selectedArchetype: Archetype?
    
    let archetypes = [
    Archetype(iconName: "chart.line.uptrend.xyaxis", title: "Strategist", description: "Analytical, deliberate, focused on planning."),
    Archetype(iconName: "graduationcap.fill", title: "Scholar", description: "Curious, disciplined, driven by knowledge."),
    Archetype(iconName: "hammer.fill", title: "Creator", description: "Imaginative, expressive, driven to build."),
    Archetype(iconName: "map.fill", title: "Explorer ", description: "Curious, adaptable, willing to discover.")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.asphyrBackground
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.asphyrTextPrimary)
                                .frame(width: 44, height: 44, alignment: .leading)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("STEP 2 OF 2")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.asphyrTextSecondary)
                                .tracking(1)
                            
                            HStack(spacing: 4) {
                                RectangleView(height: 2, width: 45, color: .asphyrAccentPrimary)
                                RectangleView(height: 2, width: 45, color: .asphyrAccentPrimary)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            Text("YOUR CHARACTER")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.asphyrTextPrimary)
                            Spacer()

                            Character()
                            
                            Spacer()
                            
                            Text(selectedArchetypeID != nil ? (selectedArchetype?.title.uppercased() ?? "") : "WHO WILL YOU BECOME?")
                                .font(selectedArchetype != nil ? .system(size: 20, weight: .bold) : .system(size: 16, weight: .medium))
                                .foregroundStyle(Color.asphyrTextPrimary)
                            
                            Text("HOW WILL YOU APPROACH YOUR GROWTH?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.asphyrTextPrimary)
        
                            VStack(spacing: 12) {
                                ForEach(archetypes) { item in
                                    ArchetypeCard(
                                        archetype: item,
                                        isSelected: selectedArchetypeID == item.id
                                    )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedArchetypeID = item.id
                                            selectedArchetype = item
                                        }
                                    }
                                }
                            }
                            
                            PrimaryButton(name: "BEGIN") {
                                if selectedArchetypeID != nil {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isShowingNextScreen = true
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationDestination(isPresented: $isShowingNextScreen) {
            HomeView()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ArchetypeSelectionView()
}
