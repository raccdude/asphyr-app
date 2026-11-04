//
//  DarkPreview.swift
//  Asphyr
//

import SwiftUI

/// ASPHYR is dark-first, but previews skip `RootView`, which sets dark mode in the
/// app. Every preview uses this trait, so the canvas matches the app.
private struct DarkPreview: PreviewModifier {
    func body(content: Content, context: Void) -> some View {
        content.preferredColorScheme(.dark)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var dark: PreviewTrait<Preview.ViewTraits> {
        .modifier(DarkPreview())
    }
}
