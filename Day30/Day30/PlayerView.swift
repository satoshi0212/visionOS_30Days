import AVKit
import SwiftUI

struct PlayerView: View, UIViewControllerRepresentable {

    @Environment(PlayerModel.self) private var model

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = model.makePlayerViewController()
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        Task { @MainActor in
            controller.contextualActions = []
        }
    }
}
