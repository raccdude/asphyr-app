//
//  QuestCompletionCard.swift
//  Asphyr
//

import SwiftUI

/// Home's card once every quest is finished and nothing is active or available.
struct QuestCompletionCard: View {
    let questCount: Int
    let xp: Int
    let onCreateQuest: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image("iconQuestCompleted")
                .foregroundStyle(Color.asphyrAccentPrimary)
                .frame(width: 54, height: 54)
                .background(Color.asphyrAccentPrimary.opacity(0.12), in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.asphyrAccentPrimary.opacity(0.35), lineWidth: 1)
                }
                .accessibilityHidden(true)

            Text(questCount == 1 ? "1 QUEST COMPLETED" : "\(questCount) QUESTS COMPLETED")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .padding(.top, 14)

            Text("+\(xp) XP")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrWarning)
                .padding(.top, 8)

            Text("Small progress is still progress.")
                .font(AppTypography.body)
                .foregroundStyle(Color.asphyrTextPrimary)
                .padding(.top, 14)

            Text(questCount == 1
                ? "You’ve completed today’s first step.\nWant to take another?"
                : "You’ve kept going today.\nWant to take another?")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 6)

            Button(action: onCreateQuest) {
                HStack(spacing: 6) {
                    Image("iconQuestCreateSmall")
                        .accessibilityHidden(true)

                    Text("CREATE QUEST")
                        .font(AppTypography.subheading)
                }
                .foregroundStyle(Color.asphyrAccentPrimary)
                .padding(.horizontal, 18)
                .frame(minHeight: 44)
                .background(Color.asphyrAccentPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.asphyrAccentPrimary.opacity(0.35), lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 23)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }
}

#Preview {
    QuestCompletionCard(questCount: 1, xp: 100) {}
        .padding(20)
        .background(Color.asphyrBackground)
}
