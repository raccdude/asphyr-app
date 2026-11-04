//
//  CreateAspirationView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

/// The sheet behind the "Something else" card.
struct CreateAspirationView: View {
    private enum Field: Hashable {
        case aspiration
    }

    private static let popularChoices = [
        "Artist", "Entrepreneur", "Musician", "Athlete",
        "Teacher", "Designer", "Engineer", "Writer"
    ]

    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var aspiration: String
    @State private var showsError = false

    @FocusState private var focus: Field?

    init(initialValue: String = "", onSave: @escaping (String) -> Void) {
        self.onSave = onSave
        _aspiration = State(initialValue: initialValue)
    }

    var body: some View {
        ScrollView {
            content
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .background(Color.asphyrSurface)
        .presentationDetents([.height(583)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .presentationBackground(Color.asphyrSurface)
        .animation(.easeInOut(duration: 0.2), value: showsError)
        .onChange(of: aspiration) {
            showsError = false
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            VStack(spacing: 8) {
                Image("iconSparklesLarge")
                    .foregroundStyle(Color.asphyrAccentPrimary)
                    .frame(width: 56, height: 56)
                    .background(Color.asphyrAccentPrimary.opacity(0.15), in: RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.asphyrAccentPrimary.opacity(0.3), lineWidth: 1)
                    }
                    .accessibilityHidden(true)
                    .padding(.bottom, 9)

                Text("Define your own path")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("This can be a career, role, or personal aspiration.")
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 35)

            sectionLabel("WHO DO YOU ASPIRE TO BECOME?")
                .padding(.top, 22)

            AsphyrInputField(
                placeholder: "E.g. Artist",
                icon: "iconSparklesSmall",
                text: $aspiration,
                focus: $focus,
                field: .aspiration,
                hasError: showsError,
                fill: .asphyrBackground
            )
            .textInputAutocapitalization(.words)
            .submitLabel(.done)
            .onSubmit { focus = nil }
            .padding(.top, 12)

            if showsError {
                FieldErrorRow(message: "Enter an aspiration.")
                    .padding(.top, 8)
            }

            sectionLabel("POPULAR CHOICES")
                .padding(.top, 23)

            FlowLayout(spacing: 8) {
                ForEach(Self.popularChoices, id: \.self) { choice in
                    chip(choice)
                }
            }
            .padding(.top, 11)

            PrimaryButton(title: "SAVE ASPIRATION", action: save)
                .padding(.top, 73)
                .padding(.bottom, 16)
        }
        // iOS floats the sheet 8 pt in from the screen edge, so this lines
        // the content up with the 20 pt screen margin
        .padding(.horizontal, 12)
        .padding(.top, 37)
    }

    private var header: some View {
        ZStack {
            Text("CREATE ASPIRATION")
                .font(AppTypography.subheading)
                .foregroundStyle(Color.asphyrTextPrimary)

            Button("Cancel") {
                dismiss()
            }
            .font(AppTypography.body)
            .foregroundStyle(Color.asphyrTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrTextSecondary)
    }

    private func chip(_ title: String) -> some View {
        let isSelected = aspiration.trimmingCharacters(in: .whitespacesAndNewlines) == title

        return Button {
            aspiration = title
        } label: {
            Text(title)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(isSelected ? Color.asphyrAccentPrimary : Color.asphyrTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12.5)
                .background(
                    isSelected ? Color.asphyrAccentPrimary.opacity(0.15) : Color.asphyrSurface,
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isSelected ? Color.asphyrAccentPrimary : Color.asphyrBorder, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func save() {
        let trimmed = aspiration.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            showsError = true
        } else {
            onSave(trimmed)
            dismiss()
        }
    }
}

#Preview(traits: .dark) {
    Color.asphyrBackground
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            CreateAspirationView { _ in }
        }
}
