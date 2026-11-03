//
//  OnboardingProfile.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import Foundation
import Observation

/// The answers given during onboarding. Kept in memory until a backend exists,
/// so they reset when the app relaunches.
@Observable
final class OnboardingProfile {
    var name: String = ""
    var email: String = ""
    /// Shown on Profile and Settings only. The character stays everywhere else.
    var photoData: Data?
    var color: CharacterColor = .green
    var aspiration: String?
    var archetype: Archetype?
    /// The cloak being worn, or nil for the starter look.
    var cloak: CharacterCloak?

    func clear() {
        name = ""
        email = ""
        photoData = nil
        color = .green
        aspiration = nil
        archetype = nil
        cloak = nil
    }
}
