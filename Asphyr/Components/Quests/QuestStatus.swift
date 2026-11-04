//
//  QuestStatus.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/1/26.
//

import SwiftUI

struct QuestStatus: View {
    let status: QuestStatusType

    private var isTinted: Bool {
        status != .available
    }

    var body: some View {
        HStack(spacing: status == .completed ? 5 : 6) {
            if status == .completed {
                Image("iconQuestStatusCheck")
                    .accessibilityHidden(true)
            } else {
                Circle()
                    .fill(Color.asphyrAccentPrimary)
                    .frame(width: 6, height: 6)
            }

            Text(status.rawValue)
                .font(AppTypography.captionRegular)
                .lineLimit(1)
                .fixedSize()
        }
        .foregroundStyle(isTinted ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
        .padding(.horizontal, 11)
        .frame(height: 24)
        .background(
            isTinted ? Color.asphyrAccentPrimary.opacity(0.12) : Color.asphyrSurfaceElevated,
            in: Capsule()
        )
        .overlay {
            Capsule()
                .strokeBorder(
                    isTinted ? Color.asphyrAccentPrimary.opacity(0.35) : Color.asphyrBorder,
                    lineWidth: 1
                )
        }
    }
}

#Preview(traits: .dark) {
    VStack(spacing: 16) {
        QuestStatus(status: .available)
        QuestStatus(status: .active)
        QuestStatus(status: .completed)
    }
    .padding()
    .background(Color.asphyrBackground)
}
