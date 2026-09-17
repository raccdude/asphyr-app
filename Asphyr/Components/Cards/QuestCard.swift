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
            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color("AsphyrGreen"))

                
                Text("Daily Quest".uppercased()) // questType
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("PrimaryText"))
            
                Spacer()
                
                Image(systemName: "arrow.right")
                    
                    .foregroundStyle(Color("PrimaryText"))
            }
            
            // CONTENT
            VStack(alignment: .leading, spacing: 6) {
                Text("Operating Systems")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("PrimaryText"))
                
                Text("Study deadlocks for 30 mins.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color("SecondaryText"))
        
            }

            // METADATA
            HStack(spacing: 18){
                Text("EDUCATION") // CATEGORY
                    .font(.system(size: 12))
                    .foregroundStyle(Color("PrimaryText"))
                
                Text("30 MIN") // DURATION
                    .font(.system(size: 12))
                    .foregroundStyle(Color("PrimaryText"))
                
                Spacer()
                
            }
            
            Divider()
            
            // FOOTER
            HStack(spacing: 14) {
                Text("+ 100 XP")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("PrimaryText"))
                
                Text("+5 Knowledge")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("PrimaryText"))
                
                Spacer()
                
                QuestStatus()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(Color("Surface"))
            .shadow(color: Color("AsphyrGreen"), radius: 2, x: 0, y: 1))
    }
        
}

#Preview {
    QuestCard()
}
