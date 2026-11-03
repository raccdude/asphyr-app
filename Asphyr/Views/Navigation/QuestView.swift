//
//  QuestView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct QuestView: View {
    enum QuestFilter: String, CaseIterable {
        case all = "ALL"
        case active = "ACTIVE"
        case available = "AVAILABLE"
        case completed = "COMPLETED"

        var status: QuestStatusType? {
            switch self {
            case .all: nil
            case .active: .active
            case .available: .available
            case .completed: .completed
            }
        }

        var emptyIconName: String {
            switch self {
            case .all: "iconQuestsEmptyAll"
            case .active: "iconQuestsEmptyActive"
            case .available: "iconQuestsEmptyAvailable"
            case .completed: "iconQuestsEmptyCompleted"
            }
        }

        var emptyTitle: String {
            switch self {
            case .all: "Your journey awaits."
            case .active: "No active quests."
            case .available: "You’re all caught up."
            case .completed: "No completed quests yet."
            }
        }

        var emptyMessage: String {
            switch self {
            case .all: "Nothing here yet — tap + to start a new quest."
            case .active: "Accept an available quest to start earning XP."
            case .available: "No quests waiting. Tap + to create your next one."
            case .completed: "Finish a quest and it will be recorded here."
            }
        }
    }

    @Environment(QuestStore.self) private var questStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedFilter: QuestFilter = .all
    @State private var isShowingCreateQuest = false
    @State private var questToDelete: Quest?
    @State private var selectedQuestID: UUID?
    @Namespace private var filterNamespace

    private var filteredQuests: [Quest] {
        // ALL is everything still open, so finished quests don't pile up there
        guard let status = selectedFilter.status else {
            return questStore.quests.filter { $0.status != .completed }
        }
        return questStore.quests.filter { $0.status == status }
    }

    var body: some View {
        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            if filteredQuests.isEmpty {
                ScrollView {
                    emptyState
                }
                .scrollIndicators(.hidden)
            } else {
                questSections
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .bottomTrailing) {
            createQuestButton
                .padding(.trailing, 20)
                // Sits 16pt above the tab bar
                .padding(.bottom, 4)
        }
        .navigationDestination(item: $selectedQuestID) { questID in
            QuestDetailsView(questID: questID)
        }
        .sheet(isPresented: $isShowingCreateQuest) {
            CreateQuestView()
        }
        .alert(
            "Delete this quest?",
            isPresented: Binding(
                get: { questToDelete != nil },
                set: { if !$0 { questToDelete = nil } }
            ),
            presenting: questToDelete
        ) { quest in
            Button("Delete", role: .destructive) {
                withAnimation {
                    questStore.delete(quest)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { quest in
            Text(quest.completedStepCount > 0
                ? "\(quest.title), its progress and the XP from its steps will be removed. This can’t be undone."
                : "\(quest.title) and its progress will be removed. This can’t be undone.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("QUEST LOG")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)

            Text("QUESTS")
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 4)

            filterBar
                .padding(.top, 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        // Lines up with the header on Home
        .padding(.top, 14)
        .padding(.bottom, 6)
        // Solid, so content scrolling up doesn't show behind the title
        .background(Color.asphyrBackground.ignoresSafeArea(edges: .top))
    }

    private var filterBar: some View {
        Group {
            // Two rows at the largest text sizes, so the labels aren't cut off
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 2) {
                    filterRow([.all, .active])
                    filterRow([.available, .completed])
                }
            } else {
                filterRow(QuestFilter.allCases)
            }
        }
        // 4pt plus Figma's 1pt border
        .padding(5)
        .frame(minHeight: 44)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 13))
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private func filterRow(_ filters: [QuestFilter]) -> some View {
        HStack(spacing: 2) {
            ForEach(filters, id: \.self) { filter in
                filterButton(filter)
            }
        }
    }

    private func filterButton(_ filter: QuestFilter) -> some View {
        let isSelected = selectedFilter == filter

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                selectedFilter = filter
            }
        } label: {
            Text(filter.rawValue)
                .font(AppTypography.captionMedium)
                .foregroundStyle(isSelected ? Color.asphyrTextPrimary : Color.asphyrTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.asphyrSurfaceElevated)
                            .overlay {
                                RoundedRectangle(cornerRadius: 9)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(0.05), .clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1
                                    )
                            }
                            .shadow(color: .black.opacity(0.4), radius: 0.5, x: 0, y: 1)
                            .matchedGeometryEffect(id: "selectedFilter", in: filterNamespace)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// A `List`, because swipe actions only work on its rows.
    private var questSections: some View {
        List {
            ForEach(QuestType.allCases, id: \.self) { type in
                let quests = filteredQuests.filter { $0.type == type }

                if !quests.isEmpty {
                    SectionDivider(sectionTitle: type.sectionTitle)
                        .questLogRow(top: 18)

                    ForEach(quests) { quest in
                        Button {
                            selectedQuestID = quest.id
                        } label: {
                            QuestLogCard(quest: questStore.withCurrentRewards(quest))
                        }
                        .buttonStyle(.plain)
                        .questLogRow(top: 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if questStore.canDelete(quest) {
                                    Button("Delete", systemImage: "trash") {
                                        questToDelete = quest
                                    }
                                    .tint(.asphyrError)
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
        // Lets the last card scroll clear of the create button
        .contentMargins(.bottom, 79, for: .scrollContent)
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            Image(selectedFilter.emptyIconName)
                .foregroundStyle(Color.asphyrAccentPrimary)
                .frame(width: 78, height: 78)
                .background(Color.asphyrAccentPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 24))
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.asphyrAccentPrimary.opacity(0.35), lineWidth: 1)
                }
                .accessibilityHidden(true)

            Text(selectedFilter.emptyTitle)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .padding(.top, 18)

            Text(selectedFilter.emptyMessage)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .frame(maxWidth: 250)
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 134)
        .padding(.bottom, 85)
    }

    private var createQuestButton: some View {
        Button {
            isShowingCreateQuest = true
        } label: {
            Image("iconQuestCreate")
                .foregroundStyle(Color(red: 3 / 255, green: 20 / 255, blue: 10 / 255))
                .frame(width: 56, height: 56)
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 125 / 255, green: 1, blue: 155 / 255), Color(red: 0, green: 230 / 255, blue: 59 / 255)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(alignment: .top) {
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.45), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: Color(red: 47 / 255, green: 175 / 255, blue: 79 / 255), radius: 1, x: 0, y: 2)
                }
                .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create quest")
    }
}

private extension View {
    func questLogRow(top: CGFloat) -> some View {
        listRowInsets(EdgeInsets(top: top, leading: 20, bottom: 6, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

#Preview("Default") {
    QuestView()
        .environment(QuestStore())
}

#Preview("All quest types") {
    QuestView()
        .environment(QuestStore(quests: Quest.samples))
}

#Preview("No quests") {
    QuestView()
        .environment(QuestStore(quests: []))
}

#Preview("Completed quest") {
    QuestView()
        .environment(QuestStore(quests: [
            Quest(
                type: .dailyQuest,
                title: "BUILD A SMALL MECHANIC",
                description: "Turn a simple idea into a working feature.",
                iconName: "iconQuestGamepad",
                xpReward: 100,
                status: .completed
            )
        ]))
}
