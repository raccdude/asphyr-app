//
//  AuthTopBar.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The back button and wordmark on auth screens. Replaces the system bar so
/// the header can sit lower under the Dynamic Island, which iOS doesn't allow
/// for the system back button (see docs/DESIGN-DECISIONS.md).
/// `AuthScreen` adds it through `.authTopBar()`. Welcome hides the back button
/// but keeps the wordmark in the same position.
struct AuthTopBar: View {
    var showsBackButton: Bool = true

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Text("ASPHYR")
                .font(AppTypography.wordMark)
                .tracking(1.44)
                .foregroundStyle(Color.asphyrAccentPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 52)

            if showsBackButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.asphyrTextPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .glassEffect(.regular.interactive(), in: Circle())
                // Dark glass until the app's light colors exist
                .environment(\.colorScheme, .dark)
                .accessibilityLabel("Back")
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SwipeBackEnabler().frame(width: 0, height: 0))
            }
        }
        // Keeps the wordmark in the same position without the back button
        .frame(minHeight: 44)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        // Solid, so content scrolling up doesn't show behind the wordmark
        .background(Color.asphyrBackground.ignoresSafeArea(edges: .top))
    }
}

extension View {
    /// Pins `AuthTopBar` above the screen in place of the system bar.
    func authTopBar(showsBackButton: Bool = true) -> some View {
        safeAreaInset(edge: .top, spacing: 0) {
            AuthTopBar(showsBackButton: showsBackButton)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// Hiding the system back button also turns off swipe-back. This turns it back
/// on only while the owning screen is visible, so screens that hide the back
/// button on purpose, like Welcome and Home, stay unaffected.
private struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    final class Controller: UIViewController, UIGestureRecognizerDelegate {
        private weak var previousDelegate: UIGestureRecognizerDelegate?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            guard let gesture = navigationController?.interactivePopGestureRecognizer else { return }
            previousDelegate = gesture.delegate
            gesture.delegate = self
            gesture.isEnabled = true
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.interactivePopGestureRecognizer?.delegate = previousDelegate
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}

#Preview {
    ZStack(alignment: .top) {
        Color.asphyrBackground.ignoresSafeArea()
        AuthTopBar()
    }
}
