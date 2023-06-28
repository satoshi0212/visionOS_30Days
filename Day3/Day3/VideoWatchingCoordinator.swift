import Foundation
import Combine
import GroupActivities
import AVFoundation

actor VideoWatchingCoordinator {

    @Published private(set) var sharedVideo: Video?

    private var subscriptions = Set<AnyCancellable>()
    private let coordinatorDelegate = CoordinatorDelegate()
    private var playbackCoordinator: AVPlayerPlaybackCoordinator

    init(playbackCoordinator: AVPlayerPlaybackCoordinator) {
        self.playbackCoordinator = playbackCoordinator
        self.playbackCoordinator.delegate = coordinatorDelegate
        Task {
            await startObservingSessions()
        }
    }

    private func startObservingSessions() async {
        for await session in VideoWatchingActivity.sessions() {

            cleanUpSession(groupSession)
            groupSession = session

            let stateListener = Task {
                await self.handleStateChanges(groupSession: session)
            }
            subscriptions.insert(.init { stateListener.cancel() })

            let activityListener = Task {
                await self.handleActivityChanges(groupSession: session)
            }
            subscriptions.insert(.init { activityListener.cancel() })

            session.join()
        }
    }

    private func cleanUpSession(_ session: GroupSession<VideoWatchingActivity>?) {
        guard groupSession === session else { return }

        groupSession?.leave()
        groupSession = nil
        sharedVideo = nil

        subscriptions.removeAll()
    }

    private var groupSession: GroupSession<VideoWatchingActivity>? {
        didSet {
            guard let groupSession else { return }
            playbackCoordinator.coordinateWithSession(groupSession)
        }
    }

    private func handleActivityChanges(groupSession: GroupSession<VideoWatchingActivity>) async {
        for await newActivity in groupSession.$activity.values {
            guard groupSession === self.groupSession else { return }
            updateSharedVideo(video: newActivity.video)
        }
    }

    private func handleStateChanges(groupSession: GroupSession<VideoWatchingActivity>) async {
        for await newState in groupSession.$state.values {
            if case .invalidated = newState {
                cleanUpSession(groupSession)
            }
        }
    }

    private func updateSharedVideo(video: Video) {
        coordinatorDelegate.video = video
        sharedVideo = video
    }

    func coordinatePlayback(of video: Video) async {
        guard video != sharedVideo else { return }

        let activity = VideoWatchingActivity(video: video)

        switch await activity.prepareForActivation() {
        case .activationPreferred:
            do {
                _ = try await activity.activate()
            } catch {
                print("Unable to activate the activity: \(error)")
            }
        case .activationDisabled:
            sharedVideo = nil
        default:
            break
        }
    }

    private class CoordinatorDelegate: NSObject, AVPlayerPlaybackCoordinatorDelegate {
        var video: Video?
        func playbackCoordinator(_ coordinator: AVPlayerPlaybackCoordinator,
                                 identifierFor playerItem: AVPlayerItem) -> String {
            "\(video?.id ?? -1)"
        }
    }
}
