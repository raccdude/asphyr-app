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
        HStack(spacing: 6) {
            Circle()
                .fill(Color.asphyrAccentPrimary)
                .frame(width: 6, height: 6)

            Text(status.rawValue)
                .font(AppTypography.captionRegular)
                .foregroundStyle(Color.asphyrTextPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 11)
        .frame(height: 24)
        .background(Color.asphyrSurfaceElevated, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
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
