import AVKit
import Observation

@Observable
class PlayerViewModel {

    private(set) var isTrimming = true

    private var player = AVPlayer()
    private var playerViewController: AVPlayerViewController? = nil
    private var playerItem: AVPlayerItem? = nil

    func makePlayerViewController() -> AVPlayerViewController {
        let url = Bundle.main.url(forResource: "BigBuckBunny_HD_60fps_30s", withExtension: "mp4")!

        let controller = AVPlayerViewController()
        controller.player = player

        playerItem = AVPlayerItem(url: url)
        controller.player?.replaceCurrentItem(with: playerItem)

        playerViewController = controller
        return controller
    }

    @MainActor
    func startTrimming() async {
        guard let playerViewController = playerViewController,
              playerViewController.canBeginTrimming else { return }

        isTrimming = true
        if await playerViewController.beginTrimming() {
            guard let playerItem = playerItem else { return }

            let preset = AVAssetExportPresetHighestQuality

            guard await AVAssetExportSession.compatibility(ofExportPreset: preset,
                                                           with: playerItem.asset,
                                                           outputFileType: .mp4) else {
                print("The selected preset can't export the video to the output file type.")
                return
            }

            guard let exportSession = AVAssetExportSession(asset: playerItem.asset,
                                                           presetName: preset) else {
                print("Unable to create an export session that supports the asset and preset.")
                return
            }

            let startTime = playerItem.reversePlaybackEndTime
            let endTime = playerItem.forwardPlaybackEndTime
            exportSession.timeRange = CMTimeRange(start: startTime, end: endTime)

            let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL: URL = documentsDirectory.appendingPathComponent("output.mp4")
            exportSession.outputURL = destinationURL
            exportSession.outputFileType = .mp4

            await exportSession.export()

        } else {
            // A user pinched the button to cancel their changes.
        }
        isTrimming = false
    }

    // MARK: - Transport Control

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }
}
