//
//  AsphyrSecureField.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct AsphyrSecureField: View {
    let placeholder: String
    @Binding var text: String

    @State private var isShowingPassword = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {

            Group {
                if isShowingPassword {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.asphyrTextSecondary))
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.asphyrTextSecondary))
                }
            }
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(Color.asphyrTextPrimary)
            .focused($isFocused)

            Button {
                isShowingPassword.toggle()
            } label: {
                Image(
                    systemName: isShowingPassword
                        ? "eye.slash"
                        : "eye"
                )
                .foregroundStyle(Color.asphyrTextSecondary)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 40)
        .background(Color.asphyrSurface)
        .overlay {
            RoundedRectangle(
                cornerRadius: 12
            )
            .stroke(
                isFocused
                    ? Color.asphyrAccentPrimary
                    : Color.asphyrBorder,
                lineWidth: isFocused ? 1.5 : 1
            )
        }
    }
}

