//
//  OnboardingProfile.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import Observation

/// The answers given during onboarding. Kept in memory until a backend exists,
/// so they reset when the app relaunches.
@Observable
final class OnboardingProfile {
    var name: String = ""
    var color: CharacterColor = .green
    var aspiration: String?
}
