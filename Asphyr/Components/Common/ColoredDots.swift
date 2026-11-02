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
            .frame(width: 32, height: 32)
            .overlay {
                if isSelected {
                    Circle()
                        .stroke(Color.asphyrTextPrimary, lineWidth: 2)
                        .padding(-4)
                }
            }
    }
}
