//
//  Character.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct Character: View {
    var body: some View {
        ZStack(alignment: .bottom) {
                    // 1. The Base or Shadow (Bottom layer)
                    Capsule() // Using Capsule instead of a squished Circle looks cleaner
                        .frame(width: 50, height: 12)
                        .foregroundStyle(Color.asphyrSurfaceElevated).opacity(0.5) // Slightly transparent for a shadow effect
                        .offset(y: 20)
                    
                    // 2. The Body (Middle layer)
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.asphyrSurface)
                        .offset(y: -1) // Pulls the body slightly up from the base
                    
                    // 3. The Head (Top layer)
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.asphyrSurfaceElevated)
                        .offset(y: -70) // Pulls the head up so it overlaps and sits perfectly on the body
                }
                .frame(width: 100, height: 100)
            }
    
}

#Preview {
    Character()
}
