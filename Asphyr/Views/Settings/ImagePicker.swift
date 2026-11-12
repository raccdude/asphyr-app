//
//  ImagePicker.swift
//  Asphyr
//

import SwiftUI

/// iOS's camera and photo library. The library deliberately doesn't use PhotosPicker: linking
/// PhotosUI adds about 0.85s before the app's first line of code runs, on every launch.
struct ImagePicker: UIViewControllerRepresentable {
    let source: UIImagePickerController.SourceType
    let onPick: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    static var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = source
        if source == .camera {
            picker.cameraDevice = .front
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onPick(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

extension UIImage {
    /// Profile photos show small, so they're saved at most 1024 pixels on the long side.
    /// A full camera photo would be several megabytes, over the bucket's 2 MB limit.
    func scaledForProfile() -> UIImage {
        let longestSide = max(size.width, size.height) * scale
        guard longestSide > 1024 else { return self }

        let ratio = 1024 / longestSide
        let target = CGSize(width: size.width * scale * ratio, height: size.height * scale * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
