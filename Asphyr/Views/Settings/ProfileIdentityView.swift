//
//  ProfileIdentityView.swift
//  Asphyr
//

import SwiftUI

struct ProfileIdentityView: View {
    @Environment(OnboardingProfile.self) private var profile
    @Environment(QuestStore.self) private var questStore

    @State private var name = ""
    @State private var aspiration: String?
    @State private var archetype: Archetype?
    @State private var isShowingPhotoSheet = false
    @State private var isShowingCreateAspiration = false
    @State private var isShowingCamera = false
    @State private var isShowingLibrary = false
    @State private var pendingPhotoChoice: ProfilePhotoSheet.Choice?
    @State private var toast: String?

    @FocusState private var isNameFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasChanges: Bool {
        !trimmedName.isEmpty
            && (trimmedName != profile.name || aspiration != profile.aspiration || archetype != profile.archetype)
    }

    private var detailLine: String {
        ["Level \(questStore.level)", profile.archetype.map { "The \($0.title)" }]
            .compactMap(\.self)
            .joined(separator: " · ")
    }

    /// The listed aspirations, plus a custom one if that's what's chosen.
    private var aspirationChoices: [String] {
        let listed = IdentityCreationView.aspirations.map(\.title)
        guard let aspiration, !listed.contains(aspiration) else { return listed }
        return listed + [aspiration]
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    photoButton

                    Text(profile.name.isEmpty ? "Traveler" : profile.name)
                        .font(AppTypography.screenTitle)
                        .foregroundStyle(Color.asphyrTextPrimary)
                        .padding(.top, 14)

                    Text(detailLine)
                        .font(AppTypography.bodySecondary)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .padding(.top, 5)

                    accountFields
                        .padding(.top, 26)

                    Text("IDENTITY")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)

                    identityCard
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
                // The scroll view would swallow a tap on the screen's background
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isNameFocused = false
                        }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            saveButton
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)
        }
        // The button stays at the bottom, behind the keyboard, instead of rising with it
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background {
            Color.asphyrBackground
                .ignoresSafeArea()
                .onTapGesture {
                    isNameFocused = false
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            SettingsNavigationTitle(title: "PROFILE & IDENTITY")
        }
        .onAppear {
            name = profile.name
            aspiration = profile.aspiration
            archetype = profile.archetype
        }
        .sheet(isPresented: $isShowingPhotoSheet, onDismiss: openPendingPhotoChoice) {
            ProfilePhotoSheet { choice in
                pendingPhotoChoice = choice
            }
        }
        .sheet(isPresented: $isShowingCreateAspiration) {
            CreateAspirationView(initialValue: aspirationChoices.contains(aspiration ?? "") ? "" : aspiration ?? "") { saved in
                aspiration = saved
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            ImagePicker(source: .camera) { image in
                profile.photoData = image.jpegData(compressionQuality: 0.8)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $isShowingLibrary) {
            ImagePicker(source: .photoLibrary) { image in
                profile.photoData = image.jpegData(compressionQuality: 0.8)
            }
            .ignoresSafeArea()
        }
        // The photo applies straight away, without Save Changes
        .onChange(of: profile.photoData) {
            toast = profile.photoData == nil ? "Using your character." : "Profile photo updated."
        }
        .settingsToast($toast, icon: "iconCheck")
    }

    private var photoButton: some View {
        Button {
            isNameFocused = false
            isShowingPhotoSheet = true
        } label: {
            ProfileAvatar(
                size: 96,
                cornerRadius: 30,
                characterSize: 130,
                characterOffsetY: 15
            )
            .overlay(alignment: .bottomTrailing) {
                Image("iconSettingsCamera")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color(red: 3 / 255, green: 20 / 255, blue: 10 / 255))
                    .frame(width: 34, height: 34)
                    .background(Color.asphyrAccentPrimary, in: Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(Color.asphyrBackground, lineWidth: 3)
                    }
                    .offset(x: 6, y: 6)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Change profile photo")
    }

    private var accountFields: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ACCOUNT INFORMATION")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)

            Text("DISPLAY NAME")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 12)

            field(icon: "iconSettingsPerson", isFocused: isNameFocused) {
                TextField("Your name", text: $name)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .textInputAutocapitalization(.words)
            }
            .padding(.top, 10)

            Text("EMAIL ADDRESS")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 14)

            // Changing it needs real accounts
            field(icon: "iconSettingsMail", isFocused: false) {
                Text(profile.email.isEmpty ? "Not added yet" : profile.email)
                    .font(AppTypography.body)
                    .foregroundStyle(profile.email.isEmpty ? Color.asphyrTextSecondary : Color.asphyrTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 10)
        }
    }

    private func field<Content: View>(
        icon: String,
        isFocused: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .foregroundStyle(Color.asphyrTextSecondary)
                .accessibilityHidden(true)

            content()
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isFocused ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 1)
        }
    }

    private var identityCard: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "iconSettingsLaptop", title: "Aspiration") {
                Menu {
                    Picker("Aspiration", selection: $aspiration) {
                        ForEach(aspirationChoices, id: \.self) { choice in
                            Text(choice).tag(Optional(choice))
                        }
                    }

                    Button("Something else") {
                        isShowingCreateAspiration = true
                    }
                } label: {
                    menuLabel(aspiration ?? "Choose")
                }
            }

            SettingsRowDivider()

            SettingsRow(icon: "iconSettingsTrending", title: "Archetype") {
                Menu {
                    Picker("Archetype", selection: $archetype) {
                        ForEach(Archetype.allCases) { choice in
                            Text(choice.title).tag(Optional(choice))
                        }
                    }
                } label: {
                    menuLabel(archetype?.title ?? "Choose")
                }
            }
        }
        .settingsCard()
    }

    private func menuLabel(_ title: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextPrimary)
                .lineLimit(1)

            Image("iconSettingsUpDown")
                .foregroundStyle(Color.asphyrTextSecondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(Color.asphyrSurfaceElevated, in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private var saveButton: some View {
        PrimaryButton(title: "SAVE CHANGES", action: save)
            .disabled(!hasChanges)
            .opacity(hasChanges ? 1 : 0.4)
            .animation(.easeInOut(duration: 0.2), value: hasChanges)
    }

    private func save() {
        isNameFocused = false
        let isNewIdentity = aspiration != profile.aspiration || archetype != profile.archetype

        name = trimmedName
        profile.name = trimmedName
        profile.aspiration = aspiration
        profile.archetype = archetype
        toast = "Changes saved."

        guard isNewIdentity else { return }

        // The server reads the archetype from the saved profile
        Task {
            try? await ProfileService.save(profile)
            try? await questStore.renewDailyQuestOnServer(
                aspiration: profile.aspiration,
                archetype: profile.archetype
            )
        }
    }

    private func openPendingPhotoChoice() {
        switch pendingPhotoChoice {
        case .camera: isShowingCamera = true
        case .library: isShowingLibrary = true
        case nil: break
        }
        pendingPhotoChoice = nil
    }
}
