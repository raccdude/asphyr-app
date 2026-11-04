//
//  CreateQuestView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

/// The sheet behind the quest log's + button.
struct CreateQuestView: View {
    private enum Field: Hashable {
        case title
        case description
        case step
    }

    private enum Duration: CaseIterable {
        case fifteenMinutes
        case thirtyMinutes
        case oneHour
        case twoHoursPlus

        var label: String {
            switch self {
            case .fifteenMinutes: "15m"
            case .thirtyMinutes: "30m"
            case .oneHour: "1h"
            case .twoHoursPlus: "2h+"
            }
        }

        var minutes: Int {
            switch self {
            case .fifteenMinutes: 15
            case .thirtyMinutes: 30
            case .oneHour: 60
            case .twoHoursPlus: 120
            }
        }
    }

    private static let questTypes: [QuestType] = [.mainQuest, .personalQuest]

    private static let categoryRows = [
        ["Development", "Learning", "Health"],
        ["Creative", "Career", "Social", "Other"]
    ]
    private static let categories = [
        "Development", "Learning", "Health", "Creative", "Career", "Social", "Other"
    ]

    private static let maxStepCount = 10

    @Environment(QuestStore.self) private var questStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var questType: QuestType = .personalQuest
    @State private var duration: Duration = .thirtyMinutes
    @State private var category = CreateQuestView.categories[0]
    @State private var steps: [QuestStep] = []
    @State private var newStep = ""
    @State private var showsTitleError = false
    @State private var isShowingRewardDetails = false
    @State private var showsStepsError = false
    @State private var toastMessage: String?
    @State private var toastCount = 0

    @FocusState private var focus: Field?

    private var difficulty: QuestDifficulty {
        DifficultyEstimator.estimate(title: title, description: description)
    }

    private var xpPerStep: Int {
        RewardRules.xpPerStep(difficulty: difficulty)
    }

    private var xpReward: Int {
        questType == .mainQuest
            ? xpPerStep * steps.count
            : RewardRules.xp(minutes: duration.minutes, difficulty: difficulty)
    }

    private var canCreateAnyType: Bool {
        Self.questTypes.contains { questStore.canCreate($0) }
    }

    private var trimmedNewStep: String {
        newStep.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView {
            content
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PrimaryButtonV2(title: "CREATE QUEST", action: create)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(Color.asphyrSurface)
        }
        .background(Color.asphyrSurface)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .presentationBackground(Color.asphyrSurface)
        .overlay(alignment: .top) {
            if let toastMessage {
                AsphyrToast(icon: "iconAlert", message: toastMessage)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture {
                        self.toastMessage = nil
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toastMessage)
        .task(id: toastCount) {
            await hideToastAfterDelay()
        }
        .animation(.easeInOut(duration: 0.2), value: showsTitleError)
        .animation(.easeInOut(duration: 0.2), value: showsStepsError)
        .animation(.easeInOut(duration: 0.2), value: questType)
        .animation(.easeInOut(duration: 0.2), value: steps.count)
        .onAppear {
            // Personal is the default unless its limit has been reached
            if !questStore.canCreate(.personalQuest), questStore.canCreate(.mainQuest) {
                questType = .mainQuest
            }
        }
        .onChange(of: title) {
            showsTitleError = false
        }
        .onChange(of: newStep) {
            showsStepsError = false
        }
        .onChange(of: questType) {
            showsStepsError = false
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Text("What will you accomplish?")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 30)

            sectionLabel("QUEST TITLE")
                .padding(.top, 20)

            AsphyrInputField(
                placeholder: "Enter quest title",
                icon: "iconQuestTitle",
                text: $title,
                focus: $focus,
                field: .title,
                hasError: showsTitleError,
                fill: .asphyrBackground
            )
            .submitLabel(.next)
            .onSubmit { focus = .description }
            .padding(.top, 10)

            if showsTitleError {
                FieldErrorRow(message: "Give your quest a title to continue.")
                    .padding(.top, 8)
            }

            sectionLabel("DESCRIPTION")
                .padding(.top, 22)

            descriptionField
                .padding(.top, 10)

            completionReward
                .padding(.top, 12)

            sectionLabel("QUEST TYPE")
                .padding(.top, 22)

            // Stacks at large text sizes so the titles don't break mid-word
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    questTypeCards
                }

                VStack(spacing: 8) {
                    questTypeCards
                }
            }
            .padding(.top, 10)

            if !canCreateAnyType {
                FieldErrorRow(message: "Finish a quest to create a new one.")
                    .padding(.top, 8)
            }

            if questType == .mainQuest {
                stepsSection
                    .padding(.top, 22)
            }

            // Main quests go at the user's own pace
            if questType != .mainQuest {
                sectionLabel("ESTIMATED DURATION")
                    .padding(.top, 22)

                HStack(spacing: 8) {
                    ForEach(Duration.allCases, id: \.self) { option in
                        durationButton(option)
                    }
                }
                .padding(.top, 10)
            }

            sectionLabel("CATEGORY")
                .padding(.top, 22)

            // Two even rows, so both end at the same edges
            VStack(spacing: 8) {
                ForEach(Self.categoryRows, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { option in
                            categoryChip(option)
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 37)
    }

    private var header: some View {
        // Stacks at large text sizes so Cancel doesn't overlap the title
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                cancelButton
                    .frame(maxWidth: .infinity, alignment: .leading)
                headerTitle
                    .lineLimit(1)
                    .fixedSize()
                // Keeps the title centered
                cancelButton
                    .hidden()
                    .accessibilityHidden(true)
                    .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 12) {
                cancelButton
                headerTitle
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var headerTitle: some View {
        Text("CREATE QUEST")
            .font(AppTypography.subheading)
            .foregroundStyle(Color.asphyrTextPrimary)
    }

    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .font(AppTypography.body)
        .foregroundStyle(Color.asphyrTextSecondary)
        .lineLimit(1)
        .fixedSize()
    }

    private var questTypeCards: some View {
        ForEach(Self.questTypes, id: \.self) { type in
            questTypeCard(type)
        }
    }

    private var descriptionField: some View {
        ZStack(alignment: .topLeading) {
            // Not the field's prompt, which truncates instead of wrapping
            if description.isEmpty {
                Text("What are you working on?")
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .allowsHitTesting(false)
            }

            TextField("", text: $description, axis: .vertical)
                .foregroundStyle(Color.asphyrTextPrimary)
                .tint(Color.asphyrAccentPrimary)
                .focused($focus, equals: .description)
                .accessibilityLabel("What are you working on?")
        }
        .font(AppTypography.body)
        .padding(.horizontal, 17)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, minHeight: 102, alignment: .topLeading)
        // Behind the text field, as in `AsphyrInputField`
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.asphyrBackground)
                .onTapGesture {
                    focus = .description
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(focus == .description ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                sectionLabel("STEPS")
                Spacer()
                sectionLabel("\(steps.count) / \(Self.maxStepCount)")
            }

            VStack(spacing: 8) {
                ForEach(steps) { step in
                    stepRow(step)
                }

                if steps.count < Self.maxStepCount {
                    addStepRow
                }
            }
            .padding(.top, 10)

            if showsStepsError {
                FieldErrorRow(message: "Add at least \(RewardRules.minStepsPerMainQuest) steps.")
                    .padding(.top, 8)
            }
        }
    }

    private func stepRow(_ step: QuestStep) -> some View {
        HStack(spacing: 12) {
            Text(step.title)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            Button {
                steps.removeAll { $0.id == step.id }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Remove \(step.title)")
        }
        .padding(.leading, 17)
        .padding(.trailing, 4)
        .selectionBackground(isSelected: false, cornerRadius: 12)
    }

    private var addStepRow: some View {
        HStack(spacing: 8) {
            AsphyrInputField(
                placeholder: "Add a step",
                icon: "iconQuestTitle",
                text: $newStep,
                focus: $focus,
                field: .step,
                hasError: showsStepsError,
                fill: .asphyrBackground
            )
            .submitLabel(.done)
            .onSubmit(addStep)

            Button(action: addStep) {
                Image("iconQuestCreate")
                    .foregroundStyle(trimmedNewStep.isEmpty ? Color.asphyrTextSecondary : Color.asphyrAccentPrimary)
                    .frame(width: 52, height: 52)
                    .selectionBackground(isSelected: false, cornerRadius: 14)
                    .contentShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(trimmedNewStep.isEmpty)
            .accessibilityLabel("Add step")
        }
    }

    private var completionReward: some View {
        let isBonus = questType == .personalQuest && !questStore.hasFullPersonalRewardsLeft
        let shownXP = isBonus ? RewardRules.bonusXP : xpReward
        let attributes = RewardRules.attributes(category: category, difficulty: difficulty)
        let shownAttributes = isBonus ? RewardRules.bonusAttributes(from: attributes) : attributes

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isShowingRewardDetails.toggle()
            }
        } label: {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("COMPLETION REWARD")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextPrimary)

                    Text(rewardSubtitle(isBonus: isBonus))
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(Color.asphyrTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    Image("iconQuestReward")
                        .accessibilityHidden(true)

                    Text("+\(shownXP) XP")
                        .font(AppTypography.sectionTitle)
                        .fixedSize()
                        // Rolls as the difficulty and duration change
                        .contentTransition(.numericText(value: Double(shownXP)))
                        .animation(.snappy, value: shownXP)
                }
                .foregroundStyle(Color.asphyrWarning)

                Image("iconChevronRight")
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .rotationEffect(.degrees(isShowingRewardDetails ? 90 : 0))
                    .accessibilityHidden(true)
            }

            // Tucked away so the card stays short while typing
            if isShowingRewardDetails {
                ForEach(shownAttributes, id: \.name) { attribute in
                    HStack(spacing: 8) {
                        Image(attribute.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .accessibilityHidden(true)

                        Text("+\(attribute.value) \(attribute.name)")
                            .font(AppTypography.captionMedium)
                    }
                    .foregroundStyle(Color.asphyrWarning)
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 12)
        .frame(minHeight: 69)
        .background(Color.asphyrWarning.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.asphyrWarning.opacity(0.25), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isShowingRewardDetails ? "Expanded" : "Collapsed")
    }

    private func rewardSubtitle(isBonus: Bool) -> String {
        if isBonus { return "Small bonus today" }
        if questType == .mainQuest { return "\(difficulty.rawValue.capitalized): \(xpPerStep) XP for each step" }
        return "\(difficulty.rawValue.capitalized) difficulty"
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrTextSecondary)
    }

    private func questTypeCard(_ type: QuestType) -> some View {
        let isUnavailable = !questStore.canCreate(type)

        let isSelected = questType == type && !isUnavailable

        return Button {
            if isUnavailable {
                showToast(type == .mainQuest
                    ? "Only one main quest can be open at a time."
                    : "You can have up to \(QuestStore.maxOpenPersonalQuests) open personal quests.")
            } else {
                questType = type
            }
        } label: {
            HStack(spacing: 10) {
                Image(type.iconName)
                    .foregroundStyle(isSelected ? Color.asphyrAccentPrimary : Color.asphyrTextSecondary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(type == .mainQuest ? "Main" : "Personal")
                        .font(AppTypography.subheading)
                        .foregroundStyle(Color.asphyrTextPrimary)

                    Text(questTypeDescription(type, isUnavailable: isUnavailable))
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .selectionBackground(isSelected: isSelected, cornerRadius: 12)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .opacity(isUnavailable ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func questTypeDescription(_ type: QuestType, isUnavailable: Bool) -> String {
        if isUnavailable { return type == .mainQuest ? "Already created" : "Limit reached" }
        return type == .mainQuest ? "A long-term goal" : "Just for you"
    }

    private func durationButton(_ option: Duration) -> some View {
        let isSelected = duration == option

        return Button {
            duration = option
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .strokeBorder(isSelected ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 2)
                    .frame(width: 18, height: 18)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(Color.asphyrAccentPrimary)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .accessibilityHidden(true)

                Text(option.label)
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .selectionBackground(isSelected: isSelected, cornerRadius: 12)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func categoryChip(_ option: String) -> some View {
        let isSelected = category == option

        return Button {
            category = option
        } label: {
            Text(option)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(isSelected ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, 6)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .selectionBackground(isSelected: isSelected, cornerRadius: 12)
                .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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

    private func addStep() {
        guard !trimmedNewStep.isEmpty, steps.count < Self.maxStepCount else { return }

        steps.append(QuestStep(title: trimmedNewStep))
        newStep = ""
        focus = .step
    }

    private func create() {
        guard questStore.canCreate(questType) else { return }

        // A step still in the field counts, so it isn't lost
        if questType == .mainQuest {
            addStep()
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        showsTitleError = trimmedTitle.isEmpty
        showsStepsError = questType == .mainQuest && steps.count < RewardRules.minStepsPerMainQuest

        guard !showsTitleError, !showsStepsError else { return }

        questStore.quests.append(
            Quest(
                type: questType,
                title: trimmedTitle.uppercased(),
                description: trimmedDescription.isEmpty ? nil : trimmedDescription,
                iconName: questType.iconName,
                category: category.uppercased(),
                difficulty: difficulty,
                durationMinutes: questType == .mainQuest ? nil : duration.minutes,
                xpReward: xpReward,
                attributeRewards: RewardRules.attributes(category: category, difficulty: difficulty),
                status: .available,
                steps: questType == .mainQuest ? steps : []
            )
        )
        dismiss()
    }
}

private extension View {
    func selectionBackground(isSelected: Bool, cornerRadius: CGFloat) -> some View {
        background(
            isSelected ? Color.asphyrAccentPrimary.opacity(0.12) : Color.asphyrBackground,
            in: RoundedRectangle(cornerRadius: cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(isSelected ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 1)
        }
    }
}

#Preview {
    Color.asphyrBackground
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            CreateQuestView()
                .environment(QuestStore())
        }
}
