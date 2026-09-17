//
//  User.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/10/26.
//

import Foundation

struct User: Identifiable {
    let id = UUID()
    let username: String
    let password: String
    let email: String
}
