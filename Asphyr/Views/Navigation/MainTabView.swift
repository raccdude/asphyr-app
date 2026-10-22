//
//  MainTabView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        
        TabView {
            HomeView()
                .tabItem {
                    Label("HOME", systemImage: "house.fill")
                }
            
            QuestView()
                .tabItem {
                    Label("QUEST", systemImage: "scroll.fill")
                }
            
            JourneyView()
                .tabItem {
                    Label("JOURNEY", systemImage: "map.fill")
                }
            
            CharacterView()
                .tabItem {
                    Label("CHARACTER", systemImage: "person.fill")
                }
        }
        .tint(Color.asphyrAccentPrimary)
        .toolbarBackground(Color.asphyrSurface, for: .tabBar)
        .toolbarBackgroundVisibility(.visible, for: .tabBar)
    }
}

#Preview {
    MainTabView()
}
