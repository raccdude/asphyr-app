//
//  IdentityCreationView.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

struct IdentityCreationView: View {
    private enum Field: Hashable {
        case name
    }

    private static let aspirations = [
        Aspiration(iconName: "iconLaptop", title: "Game Developer", description: "Build interactive games"),
        Aspiration(iconName: "iconWrench", title: "Mechanical Engineer", description: "Design & build systems"),
        Aspiration(iconName: "iconBulb", title: "Psychologist", description: "Understand the mind"),
        Aspiration(iconName: "iconStethoscope", title: "Doctor", description: "Heal & care for others"),
        Aspiration(iconName: "iconPen", title: "Writer", description: "Craft stories & ideas")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @Environment(AppRouter.self) private var router
    @Environment(OnboardingProfile.self) private var profile

    @State private var showsNameError = false
    @State private var showsAspirationError = false
    @State private var isShowingCreateAspiration = false
    /// Fills the sheet again if a saved custom aspiration was deselected.
    @State private var lastCustomAspiration = ""

    @FocusState private var focus: Field?

    /// The saved aspiration, when it isn't one of the listed cards.
    private var customAspiration: String? {
        guard let aspiration = profile.aspiration,
              !Self.aspirations.contains(where: { $0.title == aspiration }) else { return nil }
        return aspiration
    }

    var body: some View {
        @Bindable var profile = profile

        AuthScreen(onboardingStep: 1) {
            VStack(spacing: 0) {
                Text("BUILD YOUR IDENTITY")
                    .font(AppTypography.screenTitle)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 22)

                character
                    .padding(.top, 11)

                colorPicker
                    .padding(.top, 5)

                sectionLabel("WHAT SHOULD WE CALL YOU?")
                    .padding(.top, 25)

                AsphyrInputField(
                    placeholder: "Enter your name",
                    icon: "iconPerson",
                    text: $profile.name,
                    focus: $focus,
                    field: .name,
                    hasError: showsNameError
                )
                .textContentType(.name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit { focus = nil }
                .padding(.top, 10)

                if showsNameError {
                    FieldErrorRow(message: "Enter your name.")
                        .padding(.top, 8)
                }

                sectionLabel("WHO DO YOU ASPIRE TO BECOME?")
                    .padding(.top, 26)

                aspirationGrid
                    .padding(.top, 10)

                if showsAspirationError {
                    FieldErrorRow(message: "Choose an aspiration.")
                        .padding(.top, 8)
                }

                PrimaryButtonV2(title: "CONTINUE", action: submit)
                    .padding(.top, 24)

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 20)
            // Tapping empty space dismisses the keyboard
            .contentShape(Rectangle())
            .onTapGesture {
                focus = nil
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showsNameError)
        .animation(.easeInOut(duration: 0.2), value: showsAspirationError)
        .onChange(of: profile.name) {
            showsNameError = false
        }
        .onChange(of: profile.aspiration) {
            showsAspirationError = false
        }
        .sheet(isPresented: $isShowingCreateAspiration) {
            CreateAspirationView(initialValue: lastCustomAspiration) { saved in
                lastCustomAspiration = saved
                profile.aspiration = saved
            }
        }
    }

    private var character: some View {
        Image(profile.color.noviceImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 126, height: 126)
            .id(profile.color)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: profile.color)
            .accessibilityHidden(true)
    }

    private var colorPicker: some View {
        HStack(spacing: 6) {
            ForEach(CharacterColor.allCases) { color in
                Button {
                    profile.color = color
                } label: {
                    ColoredDots(color: color.swatch, isSelected: profile.color == color)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(color.rawValue)
                .accessibilityAddTraits(profile.color == color ? .isSelected : [])
            }
        }
    }

    private var aspirationGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.aspirations) { item in
                Button {
                    // Tapping the selected card deselects it
                    profile.aspiration = profile.aspiration == item.title ? nil : item.title
                } label: {
                    AspirationCard(aspiration: item, isSelected: profile.aspiration == item.title)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(profile.aspiration == item.title ? .isSelected : [])
            }

            Button {
                if customAspiration != nil {
                    profile.aspiration = nil
                } else {
                    isShowingCreateAspiration = true
                }
            } label: {
                AspirationCard(
                    aspiration: Aspiration(
                        iconName: "iconSparkles",
                        title: customAspiration ?? "Something else",
                        description: "Define your own path"
                    ),
                    isSelected: customAspiration != nil
                )
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(customAspiration != nil ? .isSelected : [])
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func submit() {
        focus = nil
        profile.name = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        showsNameError = profile.name.isEmpty
        showsAspirationError = profile.aspiration == nil

        if !showsNameError && !showsAspirationError {
            router.push(.archetype)
        }
    }
}

#Preview {
    NavigationStack {
        IdentityCreationView()
    }
    .environment(AppRouter())
    .environment(OnboardingProfile())
}
