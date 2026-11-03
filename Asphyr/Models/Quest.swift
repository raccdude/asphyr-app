//
//  Quest.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import Foundation

struct Quest: Identifiable {
    let id = UUID()
    let type: QuestType
    let title: String
    var description: String?
    let iconName: String
    var category: String?
    var durationMinutes: Int?
    let xpReward: Int
    var attributeReward: String?
    var status: QuestStatusType
    var steps: [QuestStep] = []

    var completedStepCount: Int {
        steps.filter(\.isDone).count
    }
}

struct QuestStep: Identifiable {
    let id = UUID()
    let title: String
    var isDone = false
}

/// The order here is the section order in the quest log.
enum QuestType: CaseIterable {
    case mainQuest
    case dailyQuest
    case personalQuest

    var title: String {
        switch self {
        case .mainQuest: "MAIN QUEST"
        case .dailyQuest: "DAILY QUEST"
        case .personalQuest: "PERSONAL QUEST"
        }
    }

    var sectionTitle: String {
        "\(title)S"
    }
}

enum QuestStatusType: String {
    case available = "AVAILABLE"
    case active = "ACTIVE"
    case completed = "COMPLETED"
}
