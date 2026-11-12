//
//  TextLimits.swift
//  Asphyr
//

import SwiftUI

/// How much can be typed in each field, so names and quests stay short enough to fit
/// cards and headers on every iPhone. The server allows more, so older text still loads.
enum TextLimits {
    static let name = 20
    static let aspiration = 30
    static let questTitle = 40
    static let questDescription = 150
    static let stepTitle = 60
    static let email = 254
    /// Supabase's own maximum.
    static let password = 72
}

extension View {
    /// Stops the text at `limit` characters, including when text is pasted.
    func characterLimit(_ limit: Int, text: Binding<String>) -> some View {
        onChange(of: text.wrappedValue) { _, newValue in
            if newValue.count > limit {
                text.wrappedValue = String(newValue.prefix(limit))
            }
        }
    }
}
