//
//  DotColor.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct ColoredDots: View {
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        
        Circle()
            .fill(color)
            .frame(width: 34, height: 34)
            .overlay( // might change or remove
                Circle()
                    .stroke(.white, lineWidth: isSelected ? 2 : 0)
                    .padding(-4)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
        
    }
}
