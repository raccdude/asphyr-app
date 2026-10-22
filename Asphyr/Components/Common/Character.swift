//
//  Character.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct Character: View {
    // 1. Add a dimension parameter with a default size for the dashboard layout
    let size: CGFloat
    
    init(size: CGFloat = 100) {
        self.size = size
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // BASE SHADOW
            Ellipse()
                .frame(width: size * 0.6, height: size * 0.12)
                .foregroundStyle(Color.asphyrSurfaceElevated)
                .opacity(0.4)
                .offset(y: size * 0.06)
            
            // BODY
            Circle()
                .frame(width: size * 0.8, height: size * 0.8)
                .foregroundStyle(Color.asphyrSurfaceElevated)
                .mask(
                    RoundedRectangle(cornerRadius: size * 0.16)
                        .frame(height: size * 0.55)
                        .offset(y: -(size * 0.12))
                )
            
            // HEAD
            Circle()
                .frame(width: size * 0.46, height: size * 0.46)
                .foregroundStyle(Color.asphyrSurfaceElevated)
                .offset(y: -(size * 0.7))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        Character()
        
        Character(size: 180)
    }
}
