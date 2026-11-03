//
//  XPBar.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

struct XPBar: View {
    /// From 0 to 1.
    var progress: CGFloat = 0
    var height: CGFloat = 8
    var trackColor: Color = .asphyrSurfaceElevated

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(trackColor)
            .frame(height: height)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0, green: 201 / 255, blue: 52 / 255), .asphyrAccentPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progress)
                        .shadow(color: Color.asphyrAccentPrimary.opacity(0.5), radius: 6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }
}

#Preview {
    XPBar()
}
