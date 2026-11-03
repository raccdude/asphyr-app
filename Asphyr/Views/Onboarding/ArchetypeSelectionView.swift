//
//  ArchetypeSelectionView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct ArchetypeSelectionView: View {
    @Environment(AppRouter.self) private var router
    @Environment(OnboardingProfile.self) private var profile

    @State private var showsArchetypeError = false

    private var imageName: String {
        profile.color.noviceImageName(holdingItemOf: profile.archetype)
    }

    var body: some View {
        AuthScreen(onboardingStep: 2) {
            VStack(spacing: 0) {
                Text("YOUR CHARACTER")
                    .font(AppTypography.screenTitle)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 22)

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 126, height: 126)
                    .id(imageName)
                    .transition(.opacity)
                    .accessibilityHidden(true)
                    .padding(.top, 11)

                Text(profile.archetype.map { "THE \($0.title.uppercased())" } ?? "WHO WILL YOU BECOME?")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 11)

                Text("HOW WILL YOU APPROACH YOUR GROWTH?")
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 26)

                VStack(spacing: 10) {
                    ForEach(Archetype.allCases) { archetype in
                        Button {
                            // Tapping the selected card deselects it
                            profile.archetype = profile.archetype == archetype ? nil : archetype
                        } label: {
                            ArchetypeCard(archetype: archetype, isSelected: profile.archetype == archetype)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(profile.archetype == archetype ? .isSelected : [])
                    }
                }
                .padding(.top, 14)

                if showsArchetypeError {
                    FieldErrorRow(message: "Choose an archetype.")
                        .padding(.top, 8)
                }

                Spacer(minLength: 24)

                PrimaryButtonV2(title: "BEGIN", action: begin)
            }
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut(duration: 0.2), value: profile.archetype)
        .animation(.easeInOut(duration: 0.2), value: showsArchetypeError)
        .onChange(of: profile.archetype) {
            showsArchetypeError = false
        }
    }

    private func begin() {
        showsArchetypeError = profile.archetype == nil

        if !showsArchetypeError {
            router.enterApp()
        }
    }
}

#Preview {
    NavigationStack {
        ArchetypeSelectionView()
    }
    .environment(AppRouter())
    .environment(OnboardingProfile())
}
