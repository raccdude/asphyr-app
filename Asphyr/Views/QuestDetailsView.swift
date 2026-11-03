//
//  QuestDetailsView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct QuestDetailsView: View {
    let questID: UUID

    @Environment(QuestStore.self) private var questStore
    @Environment(\.dismiss) private var dismiss

    @State private var isConfirmingAbandon = false
    @State private var showsStepsError = false
    @State private var toastMessage: String?
    @State private var toastCount = 0

    private var quest: Quest? {
        questStore.quests.first { $0.id == questID }
    }

    var body: some View {
        Group {
            if let quest {
                content(quest)
                    .authTopBar(title: quest.type.title)
            }
        }
        .background(Color.asphyrBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            if let toastMessage {
                AsphyrToast(icon: "iconAlert", message: toastMessage)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture {
                        self.toastMessage = nil
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toastMessage)
        .animation(.easeInOut(duration: 0.2), value: quest?.status)
        .animation(.easeInOut(duration: 0.2), value: showsStepsError)
        .task(id: toastCount) {
            await hideToastAfterDelay()
        }
        .alert("Abandon this quest?", isPresented: $isConfirmingAbandon) {
            Button("Abandon", role: .destructive) {
                if let quest {
                    questStore.abandon(quest)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("It goes back to your available quests, and its timer resets.")
        }
    }

    private func content(_ quest: Quest) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                summary(quest)
                    .padding(.top, 16)

                if quest.hasTimer {
                    timerCard(quest)
                        .padding(.top, 20)
                }

                Rectangle()
                    .fill(Color.asphyrBorder)
                    .frame(height: 1)
                    .padding(.top, quest.hasTimer ? 24 : 8)

                if let objective = quest.objective {
                    sectionLabel("OBJECTIVE")
                        .padding(.top, 23)

                    Text(objective)
                        .font(AppTypography.body)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .padding(.top, 8)
                }

                if !quest.steps.isEmpty {
                    stepsSection(quest)
                        .padding(.top, 23)
                }

                let details = detailRows(quest)
                if !details.isEmpty {
                    sectionLabel("DETAILS")
                        .padding(.top, 26)

                    infoTable(details, valueColor: .asphyrTextPrimary)
                        .padding(.top, 10)
                }

                sectionLabel("REWARDS")
                    .padding(.top, 26)

                infoTable(rewardRows(quest), valueColor: .asphyrWarning)
                    .padding(.top, 10)

                actions(quest)
                    .padding(.top, 26)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }

    private func summary(_ quest: Quest) -> some View {
        let isActive = quest.status == .active

        return VStack(spacing: 0) {
            Image(quest.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(isActive ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
                .frame(width: 60, height: 60)
                .background(
                    isActive ? Color.asphyrAccentPrimary.opacity(0.12) : Color.asphyrSurfaceElevated,
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            isActive ? Color.asphyrAccentPrimary.opacity(0.35) : Color.asphyrBorder,
                            lineWidth: 1
                        )
                }
                .accessibilityHidden(true)

            Text(quest.title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 16)

            if let description = quest.description {
                Text(description)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .padding(.top, 8)
            }

            QuestStatus(status: quest.status)
                .padding(.top, 14)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private func timerCard(_ quest: Quest) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image("iconQuestTimer")
                        .foregroundStyle(Color.asphyrAccentPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.asphyrAccentPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("ELAPSED")
                            .font(AppTypography.captionMedium)
                            .foregroundStyle(Color.asphyrTextSecondary)

                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text(quest.elapsed(at: context.date).timerText)
                                .font(AppTypography.screenTitle)
                                .foregroundStyle(Color.asphyrTextPrimary)
                                .monospacedDigit()

                            Text("/ \(TimeInterval((quest.durationMinutes ?? 0) * 60).timerText)")
                                .font(AppTypography.bodySecondary)
                                .foregroundStyle(Color.asphyrTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    pauseButton(quest)
                }

                XPBar(
                    progress: quest.timerProgress(at: context.date),
                    height: 6,
                    trackColor: .asphyrSurfaceElevated
                )
                .padding(.top, 14)

                HStack {
                    if let startedAt = quest.startedAt {
                        Text("Started \(startedAt.formatted(date: .omitted, time: .shortened))")
                            .foregroundStyle(Color.asphyrTextSecondary)
                    }

                    Spacer(minLength: 8)

                    Text(quest.isPaused ? "Paused" : quest.timeLeftText(at: context.date))
                        .foregroundStyle(quest.isPaused ? Color.asphyrWarning : Color.asphyrAccentPrimary)
                }
                .font(AppTypography.captionMedium)
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 17)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.asphyrAccentPrimary.opacity(0.35), lineWidth: 1)
        }
    }

    private func pauseButton(_ quest: Quest) -> some View {
        Button {
            questStore.togglePause(quest)
        } label: {
            HStack(spacing: 6) {
                if quest.isPaused {
                    // Figma has no icon for resuming
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                } else {
                    Image("iconQuestPause")
                }

                Text(quest.isPaused ? "Resume" : "Pause")
                    .font(AppTypography.bodySecondary)
                    .fixedSize()
            }
            .foregroundStyle(Color.asphyrTextPrimary)
            .padding(.horizontal, 14)
            .frame(minHeight: 36)
            .background(Color.asphyrSurfaceElevated, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(Color.asphyrBorder, lineWidth: 1)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func stepsSection(_ quest: Quest) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                sectionLabel("STEPS")
                Spacer()
                Text("\(quest.completedStepCount) / \(quest.steps.count)")
                    .font(AppTypography.captionMedium)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }

            XPBar(
                progress: CGFloat(quest.completedStepCount) / CGFloat(quest.steps.count),
                height: 6,
                trackColor: .asphyrSurfaceElevated
            )
            .padding(.top, 10)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(quest.steps) { step in
                    Button {
                        questStore.toggleStep(step, in: quest)
                        showsStepsError = false
                    } label: {
                        QuestStepRow(step: step)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    // Accept the quest before ticking its steps
                    .disabled(quest.status != .active)
                }
            }
            .padding(.top, 6)

            if showsStepsError {
                FieldErrorRow(message: "Finish every step to complete this quest.")
                    .padding(.top, 8)
            }
        }
    }

    @ViewBuilder
    private func actions(_ quest: Quest) -> some View {
        switch quest.status {
        case .available:
            PrimaryButtonV2(title: "ACCEPT QUEST") {
                if questStore.canStart(quest) {
                    questStore.start(quest)
                } else {
                    showToast("You already have an active quest. Finish or abandon it first.")
                }
            }
        case .active:
            VStack(spacing: 14) {
                PrimaryButtonV2(title: "COMPLETE QUEST") {
                    if questStore.canComplete(quest) {
                        questStore.complete(quest)
                        dismiss()
                    } else {
                        showsStepsError = true
                    }
                }

                Button("Abandon quest") {
                    isConfirmingAbandon = true
                }
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
            }
        case .completed:
            EmptyView()
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrTextPrimary)
    }

    private func detailRows(_ quest: Quest) -> [(title: String, value: String)] {
        var rows: [(title: String, value: String)] = []

        if let durationMinutes = quest.durationMinutes {
            rows.append(("DURATION", "\(durationMinutes) MIN"))
        }
        if let difficulty = quest.difficulty {
            rows.append(("DIFFICULTY", difficulty))
        }
        if let category = quest.category {
            rows.append(("CATEGORY", category))
        }

        return rows
    }

    private func rewardRows(_ quest: Quest) -> [(title: String, value: String)] {
        var rows: [(title: String, value: String)] = [("EXPERIENCE", "+\(quest.xpReward)")]

        if !quest.steps.isEmpty {
            rows.append(("EARNED SO FAR", "+\(quest.completedStepCount * QuestReward.xpPerStep)"))
        }

        rows += quest.attributeRewards.map { ($0.name, "+\($0.value)") }
        return rows
    }

    private func infoTable(_ rows: [(title: String, value: String)], valueColor: Color) -> some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { index in
                if index > 0 {
                    Rectangle()
                        .fill(Color.asphyrBorder)
                        .frame(height: 1)
                }

                HStack(spacing: 12) {
                    Text(rows[index].title)
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)

                    Spacer(minLength: 0)

                    Text(rows[index].value)
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(valueColor)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal, 17)
                .frame(minHeight: 43)
                .accessibilityElement(children: .combine)
            }
        }
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        toastCount += 1
    }

    private func hideToastAfterDelay() async {
        guard toastMessage != nil else { return }

        do {
            try await Task.sleep(for: .seconds(3))
            toastMessage = nil
        } catch {
            // A newer toast restarted the delay
        }
    }
}

#Preview("Available") {
    let store = QuestStore()

    NavigationStack {
        QuestDetailsView(questID: store.quests[0].id)
    }
    .environment(store)
}

#Preview("Main quest") {
    let store = QuestStore(quests: Quest.samples)

    NavigationStack {
        QuestDetailsView(questID: store.quests[0].id)
    }
    .environment(store)
}

#Preview("Active with timer") {
    let store = QuestStore(quests: Quest.samples)

    NavigationStack {
        QuestDetailsView(questID: store.quests[1].id)
    }
    .environment(store)
}
