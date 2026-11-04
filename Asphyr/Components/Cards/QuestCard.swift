//
//  QuestCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

/// Home's quest card.
struct QuestCard: View {
    let quest: Quest

    private var isActive: Bool {
        quest.status == .active
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(quest.iconName)
                    .foregroundStyle(isActive ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        isActive ? Color.asphyrAccentPrimary.opacity(0.12) : Color.asphyrSurfaceElevated,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.type.title)
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)

                    Text(quest.title)
                        .font(AppTypography.subheading)
                        .foregroundStyle(Color.asphyrTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image("iconChevronRight")
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .accessibilityHidden(true)
            }

            if let description = quest.description {
                Text(description)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .padding(.top, 14)
            }

            HStack(spacing: 8) {
                if let category = quest.category {
                    tag {
                        Text(category)
                    }
                }

                if let durationMinutes = quest.durationMinutes {
                    tag {
                        Image("iconClockSmall")
                            .accessibilityHidden(true)
                        Text("\(durationMinutes) MIN")
                    }
                }
            }
            .padding(.top, 14)

            if quest.hasTimer {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    VStack(spacing: 8) {
                        HStack {
                            Text(quest.timeLeftText(at: context.date))
                                .font(AppTypography.bodySecondarySemiBold)
                                .foregroundStyle(Color.asphyrTextPrimary)

                            Spacer(minLength: 8)

                            if quest.isPaused {
                                Text("Paused")
                                    .font(AppTypography.captionMedium)
                                    .foregroundStyle(Color.asphyrWarning)
                            }
                        }

                        // The active card's surface would hide the usual track
                        QuestTimerBar(
                            progress: quest.timerProgress(at: context.date),
                            isPaused: quest.isPaused,
                            trackColor: .asphyrBackground
                        )
                    }
                }
                .padding(.top, 14)
            }

            Rectangle()
                .fill(Color.asphyrBorder)
                .frame(height: 1)
                .padding(.top, 14)

            // Stacks at large text sizes so nothing is cut off
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) {
                    rewards
                    Spacer(minLength: 8)
                    QuestStatus(status: quest.status)
                }

                VStack(alignment: .leading, spacing: 8) {
                    rewards
                    QuestStatus(status: quest.status)
                }
            }
            .padding(.top, 14)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .questCardBackground(isActive: isActive)
    }

    private var rewards: some View {
        HStack(spacing: 0) {
            Image("iconLightning")
                .accessibilityHidden(true)

            Text("+\(quest.xpReward) XP")
                .padding(.leading, 4)

            if let attributeReward = quest.attributeRewards.first {
                Text("+\(attributeReward.value) \(attributeReward.name)")
                    .padding(.leading, 12)
            }
        }
        .font(AppTypography.captionMedium)
        .foregroundStyle(Color.asphyrWarning)
        .lineLimit(1)
    }

    private func tag<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 5) {
            content()
        }
        .font(AppTypography.captionMedium)
        .foregroundStyle(Color.asphyrTextSecondary)
        .padding(.horizontal, 10)
        .frame(height: 25)
        // The active card is already the elevated color
        .background(isActive ? Color.asphyrBackground : Color.asphyrSurfaceElevated, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    QuestCard(quest: Quest.sampleDaily)
}

extension View {
    /// Active quests sit on the elevated surface with a green lower edge.
    func questCardBackground(isActive: Bool) -> some View {
        background {
            if isActive {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.asphyrSurfaceElevated)
                    .overlay {
                        CometBorder(cornerRadius: 16)
                    }
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.asphyrSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.asphyrBorder, lineWidth: 1)
                    }
            }
        }
    }
}
