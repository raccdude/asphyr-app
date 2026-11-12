//
//  OnboardingProfile.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import Foundation
import Observation

/// The answers given during onboarding, saved to the account by `ProfileService`.
/// The photo stays in memory until backend step 5, so it resets on relaunch.
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

    /// Whether onboarding was finished, so a returning user can skip it.
    var isComplete: Bool {
        !name.isEmpty && aspiration != nil && archetype != nil
    }

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
