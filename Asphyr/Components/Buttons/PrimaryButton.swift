//
//  PrimaryButton.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct PrimaryButton: View {
    let name: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(name)
                .font(.system(size: 20, weight: .semibold)) // change
                .foregroundStyle(Color.asphyrBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                //.padding(.vertical, 20)
                .background(
                    LinearGradient(
                        colors: [
                            Color.asphyrAccentSecondary,
                            Color.asphyrAccentPrimary
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .shadow(color: Color.asphyrAccentPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
        }
    }
}
