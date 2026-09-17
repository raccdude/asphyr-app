//
//  QuestStatus.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/1/26.
//

import SwiftUI

struct QuestStatus: View {
    
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 10))
            
            Text("AVAILABLE") // STATUS
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Color("AsphyrGreen"))
        .clipShape(RoundedRectangle(cornerRadius: 999))
        .shadow(radius: 6)
    }
}

#Preview {
    QuestStatus()
}
