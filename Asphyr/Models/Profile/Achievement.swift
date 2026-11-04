//
//  Achievement.swift
//  Asphyr
//

import Foundation

/// The badges on Character. Earned badges stay earned, like cloaks.
enum Achievement: CaseIterable, Hashable {
    case firstQuest
    case levelTwo
    case consistency
    case scholar
    case builder
    case master

    var title: String {
        switch self {
        case .firstQuest: "First Quest"
        case .levelTwo: "Level 2"
        case .consistency: "Consistency"
        case .scholar: "Scholar"
        case .builder: "Builder"
        case .master: "Master"
        }
    }

    var requirement: String {
        switch self {
        case .firstQuest: "Complete your first quest."
        case .levelTwo: "Reach level 2."
        case .consistency: "Complete quests on 3 different days."
        case .scholar: "Reach 25 Knowledge."
        case .builder: "Reach 25 Problem Solving."
        case .master: "Reach level 5."
        }
    }

    /// The level this badge depends on, if any.
    var requiredLevel: Int? {
        switch self {
        case .levelTwo: 2
        case .master: 5
        default: nil
        }
    }

    var iconName: String {
        switch self {
        case .firstQuest: "iconBadgeFlag"
        case .levelTwo: "iconBadgeStar"
        case .consistency: "iconBadgeFlame"
        case .scholar: "iconAttributeKnowledge"
        case .builder: "iconAttributeProblemSolving"
        case .master: "iconJourneyCrown"
        }
    }

    static func earned(
        completionDates: [Date],
        level: Int,
        knowledge: Int,
        problemSolving: Int,
        calendar: Calendar = .current
    ) -> Set<Achievement> {
        let days = Set(completionDates.map { calendar.startOfDay(for: $0) })
        var earned = Set<Achievement>()

        if !completionDates.isEmpty { earned.insert(.firstQuest) }
        if level >= 2 { earned.insert(.levelTwo) }
        if days.count >= 3 { earned.insert(.consistency) }
        if knowledge >= 25 { earned.insert(.scholar) }
        if problemSolving >= 25 { earned.insert(.builder) }
        if level >= 5 { earned.insert(.master) }

        return earned
    }
}
