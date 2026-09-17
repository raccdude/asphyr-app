//
//  AsphyrTextField.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct AsphyrTextField: View {
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.asphyrTextSecondary))
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(Color.asphyrTextPrimary)
            .padding(.horizontal, 20)
            .frame(height: 40)
            .background(Color.asphyrSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
            .focused($isFocused)
    }
}
