//
//  QuestCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/27/26.
//

import SwiftUI

struct QuestCard: View {
    //let questType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // HEADER
            HStack(spacing: 12) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.asphyrTextSecondary)

                Text("Daily Quest".uppercased()) // questType
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.asphyrTextSecondary)
            
                Spacer()
                
                Image(systemName: "chevron.forward.dotted.chevron.forward")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            
            // CONTENT
            VStack(alignment: .leading, spacing: 8) {
                Text("BUILD A SMALL MECHANIC")
                    .font(.system(size: 16, weight: .medium))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.asphyrTextPrimary)
                
                Text("Turn a simple idea into a working feature.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .padding(.bottom, 12)

            // METADATA
            HStack {
                Text("DEVELOPMENT") // CATEGORY
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.asphyrTextSecondary)
                
                Spacer()
                
                Text("30 MIN") // DURATION
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            
            RectangleView(height: 1.5, color: Color.asphyrSurfaceElevated)

            // FOOTER
            HStack(spacing: 14) {
                Text("+100 XP")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.asphyrWarning) // change
                
                Text("+5 CREATIVITY")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.asphyrWarning)
                
                Spacer()
                
                QuestStatus(status: .available)
            }
        }
        .padding(20)
        
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.asphyrSurface)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.asphyrBorder))
        )
        
            //.shadow(color: Color.asphyrAccentPrimary, radius: 2, x: 0, y: 1))
    }
}

#Preview {
    QuestCard()
}
