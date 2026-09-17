//
//  Quest.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import Foundation

struct Quest {
    let questType: QuestType
    let title: String
    let description: String
    let objective: String
    let catergory: String
    let duration: Int
    let xpReward: Int
    let attributeReward: Int
    //let status: QuestStatus
}

enum QuestType {
    case dailyQuest
    case personalQuest
    case mainQuest
}

/*
 enum QuestStatus {
 case available
 case inProgress
 case completed
 }
 
 */
