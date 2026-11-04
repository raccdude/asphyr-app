//
//  QuestLogCard.swift
//  Asphyr
//

import SwiftUI

/// A quest in the quest log. Quests with steps show their checklist, and the
/// rest link to their details once Quest Details is rebuilt.
struct QuestLogCard: View {
    let quest: Quest

    private var isActive: Bool {
        quest.status == .active
    }

    var body: some View {
        Group {
            if quest.steps.isEmpty {
                summary
            } else {
                checklist
            }
        }
        // 18pt plus Figma's 1pt border
        .padding(19)
        .frame(maxWidth: .infinity, alignment: .leading)
        .questCardBackground(isActive: isActive)
        .opacity(quest.status == .completed ? 0.65 : 1)
    }

    private var summary: some View {
        HStack(alignment: .top, spacing: 14) {
            icon

            VStack(alignment: .leading, spacing: 0) {
                Text(quest.title)
                    .font(AppTypography.subheading)
                    .foregroundStyle(Color.asphyrTextPrimary)

                if let description = quest.description {
                    Text(description)
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .frame(maxWidth: 208, alignment: .leading)
                        .padding(.top, 5)
                }

                // Stacks at large text sizes so nothing is cut off
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) {
                        QuestStatus(status: quest.status)
                        xpReward
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        QuestStatus(status: quest.status)
                        xpReward
                    }
                }
                .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image("iconChevronRight")
                .foregroundStyle(Color.asphyrTextSecondary)
                .accessibilityHidden(true)
        }
    }

    private var checklist: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                icon

                VStack(alignment: .leading, spacing: 8) {
                    // A long title wraps instead of running into the step count
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(quest.title)
                            .font(AppTypography.subheading)
                            .foregroundStyle(Color.asphyrTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("\(quest.completedStepCount) / \(quest.steps.count) steps")
                            .font(AppTypography.bodySecondary)
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .fixedSize()
                    }

                    // Stacks at large text sizes so nothing is cut off
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 12) {
                            QuestStatus(status: quest.status)
                            xpReward
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            QuestStatus(status: quest.status)
                            xpReward
                        }
                    }
                }
                .frame(minHeight: 46)
            }

            XPBar(
                progress: CGFloat(quest.completedStepCount) / CGFloat(quest.steps.count),
                height: 6,
                trackColor: .asphyrBackground
            )
            .padding(.top, 14)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(quest.steps) { step in
                    QuestStepRow(step: step)
                }
            }
            .padding(.top, 14)
        }
    }

    private var icon: some View {
        Image(quest.iconName)
            .foregroundStyle(Color.asphyrTextPrimary)
            .frame(width: 46, height: 46)
            .background(isActive ? Color.asphyrBackground : Color.asphyrSurfaceElevated, in: Circle())
            .accessibilityHidden(true)
    }

    private var xpReward: some View {
        Text("+\(quest.xpReward) XP")
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrWarning)
            .lineLimit(1)
            .fixedSize()
    }
}

struct QuestStepRow: View {
    let step: QuestStep

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if step.isDone {
                    Image("iconQuestStepCheck")
                        .foregroundStyle(Color.asphyrBackground)
                        .frame(width: 16, height: 16)
                        .background(Color.asphyrAccentPrimary, in: Circle())
                } else {
                    Circle()
                        .strokeBorder(Color.asphyrBorder, lineWidth: 1)
                        .frame(width: 16, height: 16)
                }
            }
            .accessibilityHidden(true)

            Text(step.title)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(step.isDone ? Color.asphyrTextSecondary : Color.asphyrTextPrimary)
                .multilineTextAlignment(.leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(step.isDone ? "Done" : "Not done")
    }
}

#Preview(traits: .dark) {
    VStack(spacing: 12) {
        ForEach(Quest.samples) { quest in
            QuestLogCard(quest: quest)
        }
    }
    .padding(20)
    .background(Color.asphyrBackground)
}
