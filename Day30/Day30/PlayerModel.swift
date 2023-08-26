import AVKit
import Combine
import Observation

struct Video: Identifiable, Hashable, Codable {
    let id: Int
    let url: URL
    let title: String
}

enum VideoAction {
    case none
    case reset
    case darkRoom
    case lightRoom
    case fireworks

    static func convert(str: String) -> Self {
        switch str {
        case "c_reset":
            return .reset
        case "c_dark":
            return .darkRoom
        case "c_light":
            return .lightRoom
        case "c_fireworks":
            return .fireworks
        default:
            return .none
        }
    }
}

@Observable
class PlayerModel: NSObject {

    private(set) var isPlaying = false
    private(set) var isPlaybackComplete = false
    private(set) var currentItem: Video? = nil
    private(set) var videoAction: VideoAction = .reset

    private var player = AVPlayer()
    private var playerViewController: AVPlayerViewController? = nil
    private var playerViewControllerDelegate: AVPlayerViewControllerDelegate? = nil

    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        observePlayback()
        Task {
            await configureAudioSession()
        }
    }

    func makePlayerViewController() -> AVPlayerViewController {
        let delegate = PlayerViewControllerDelegate(player: self)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.delegate = delegate

        playerViewController = controller
        playerViewControllerDelegate = delegate

        return controller
    }

    private func observePlayback() {
        guard subscriptions.isEmpty else { return }

        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] status in
                self?.isPlaying = status == .playing
            }
            .store(in: &subscriptions)

        NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .map { _ in true }
            .sink { [weak self] isPlaybackComplete in
                self?.isPlaybackComplete = isPlaybackComplete
            }
            .store(in: &subscriptions)

        NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let result = InterruptionResult(notification) else { return }
                if result.type == .ended && result.options == .shouldResume {
                    self?.player.play()
                }
            }.store(in: &subscriptions)
    }

    private func configureAudioSession() async {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .moviePlayback)
        } catch {
            print("Unable to configure audio session: \(error.localizedDescription)")
        }
    }

    func loadVideo(_ video: Video) {
        currentItem = video
        isPlaybackComplete = false
        replaceCurrentItem(with: video)
        configureAudioExperience()
   }

    private func replaceCurrentItem(with video: Video) {
        let playerItem = AVPlayerItem(url: video.url)
        let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        playerItem.add(metadataOutput)
        player.replaceCurrentItem(with: playerItem)
    }

    func reset() {
        currentItem = nil
        player.replaceCurrentItem(with: nil)
        playerViewController = nil
        playerViewControllerDelegate = nil
    }

    private func configureAudioExperience() {
        let experience: AVAudioSessionSpatialExperience
        experience = .headTracked(soundStageSize: .small, anchoringStrategy: .front)
        try! AVAudioSession.sharedInstance().setIntendedSpatialExperience(experience)
    }

    // MARK: - Transport Control

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    final class PlayerViewControllerDelegate: NSObject, AVPlayerViewControllerDelegate {

        let player: PlayerModel

        init(player: PlayerModel) {
            self.player = player
        }

        func playerViewController(_ playerViewController: AVPlayerViewController,
                                  willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            Task { @MainActor in
                player.reset()
            }
        }
    }
}

struct InterruptionResult {

    let type: AVAudioSession.InterruptionType
    let options: AVAudioSession.InterruptionOptions

    init?(_ notification: Notification) {
        guard let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType,
              let options = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions else {
            return nil
        }
        self.type = type
        self.options = options
    }
}

extension PlayerModel: AVPlayerItemMetadataOutputPushDelegate {

    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        if let item = groups.first?.items.first,
           let metadataValue = item.value(forKey: "value") as? String {

            //print("Metadata value: \n \(metadataValue)")
            videoAction = VideoAction.convert(str: metadataValue)
        }
    }
}
