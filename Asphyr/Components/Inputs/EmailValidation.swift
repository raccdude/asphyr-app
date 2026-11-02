//
//  EmailValidation.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        wholeMatch(of: /[^@\s]+@[^@\s]+\.[^@\s]+/) != nil
    }
}
