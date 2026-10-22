//
//  QuestStatus.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/1/26.
//

import SwiftUI

struct QuestStatus: View {
    enum QuestStatusType: String, CaseIterable {
        case available = "AVAILABLE"
        case inProgress = "IN PROGRESS"
        case completed = "COMPLETED"
    }
    
    let status: QuestStatusType
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(Color.asphyrAccentPrimary)
            
            Text(status.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.asphyrTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 120, height: 24)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.asphyrSurfaceElevated))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.asphyrBorder, lineWidth: 1))
    }
}

#Preview {
    VStack(spacing: 16) {
        QuestStatus(status: .available)
        QuestStatus(status: .inProgress)
        QuestStatus(status: .completed)
    }
    .padding()
    .background(Color.asphyrBackground)
}
