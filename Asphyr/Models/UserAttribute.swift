//
//  UserAttribute.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import Foundation
// import SwiftData

struct UserAttribute {
    let name: String
    let value: String
    let iconName: String

    static let iconNames = [
        (name: "KNOWLEDGE", iconName: "iconAttributeKnowledge"),
        (name: "DISCIPLINE", iconName: "iconAttributeDiscipline"),
        (name: "CREATIVITY", iconName: "iconAttributeCreativity"),
        (name: "PROBLEM SOLVING", iconName: "iconAttributeProblemSolving")
    ]
}
