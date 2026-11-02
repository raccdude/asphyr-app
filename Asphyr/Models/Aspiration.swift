//
//  Aspiration.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/3/26.
//

import Foundation

struct Aspiration: Identifiable {
    let iconName: String
    let title: String
    let description: String

    var id: String { title }
}
