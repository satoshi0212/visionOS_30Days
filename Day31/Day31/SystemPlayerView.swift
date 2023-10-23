import SwiftUI
import AVKit

struct SystemPlayerView: UIViewControllerRepresentable {

    @Environment(PlayerViewModel.self) private var model

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        return  model.makePlayerViewController()
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {

    }
}
