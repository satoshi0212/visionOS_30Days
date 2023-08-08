import RealityKit
import Observation
import SwiftUI

@Observable
class ViewModel {

    var messages: [SlackMessage] = []

    let targetChannelId = ""

    private let token = "xoxp-xxx"
    private var task: Task<Void, Error>?

    private var contentEntity = Entity()
    private let roomBoundaryStart: Float = 2.0
    private let roomBoundaryEnd: Float = 6.0

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    @MainActor
    func spawnText(text: String, color: UIColor = .white, duration: Double = 6.0) -> [ModelEntity] {
        var _text = text
        var _color = color
        var _type: SlackMessageCustomType = .regular

        let components = text.components(separatedBy: ",")
        if components.count == 3 {
            _text = components[0]
            _color = UIColor(hex: components[1]) ?? color
            _type = SlackMessageCustomType.make(oneLetter: components[2])
        }

        let textMeshResource: MeshResource = .generateText(_text,
                                                           extrusionDepth: 0.04,
                                                           font: .systemFont(ofSize: 0.35),
                                                           containerFrame: .zero,
                                                           alignment: .center,
                                                           lineBreakMode: .byWordWrapping)

        let material = UnlitMaterial(color: _color)

        if _type == .danmaku {
            var textEntities: [ModelEntity] = []
            for _ in 0...60 {
                let textEntity = ModelEntity(mesh: textMeshResource, materials: [material])
                let randamX = Float.random(in: -0.0...9.0)
                let randamY = Float.random(in: -1.5...2.5)
                let randamZ = Float.random(in: -1.5...1.0)
                textEntity.position = SIMD3<Float>(x: roomBoundaryStart + randamX, y: 1.5 + randamY, z: -2.0 + randamZ)
                contentEntity.addChild(textEntity)
                let animation = generateMovementAnimations(entity: textEntity, duration: duration, isDanmaku: true)
                textEntity.playAnimation(animation, transitionDuration: duration, startsPaused: false)
                textEntities.append(textEntity)
            }
            return textEntities
        } else {
            let textEntity = ModelEntity(mesh: textMeshResource, materials: [material])
            textEntity.position = SIMD3(x: roomBoundaryStart, y: 1.5, z: -2.0)
            contentEntity.addChild(textEntity)
            let animation = generateMovementAnimations(entity: textEntity, duration: duration)
            textEntity.playAnimation(animation, transitionDuration: duration, startsPaused: false)
            return [textEntity]
        }
    }

    func removeTextEntities(textEntities: [ModelEntity], lifetime: UInt32 = 8) async {
        sleep(lifetime)
        Task { @MainActor in
            textEntities.forEach { $0.removeFromParent() }
        }
    }

    func fetchDataOnce(channelId: String, limit: Int = 1) async throws {
        Task {
            if let response = try await self.fetchChannelHistory(token: token, channelId: channelId, limit: limit) {
                self.messages = response.messages
            }
        }
    }

    // fetch data at 1 second intervals
    func startFetchingData(channelId: String, limit: Int = 1) async throws {
        guard task == nil else { return }

        task = Task {
            do {
                while true {
                    print("fetchData task called.")
                    if let response = try await self.fetchChannelHistory(token: token, channelId: channelId, limit: limit) {
                        self.messages = response.messages
                    }
                    try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
                }
            } catch {
                guard !Task.isCancelled else { return }
                print("Error fetching data: \(error)")
            }
        }
    }

    func stopFetchingData() {
        task?.cancel()
        task = nil
    }

    func filterNewMessages(oldMessages: [SlackMessage], newMessages: [SlackMessage]) -> [String] {
        let excludeIds: [String] = oldMessages.map { $0.ts }
        var items: [String] = []
        for message in newMessages {
            if excludeIds.contains(message.ts) { continue }
            items.append(contentsOf: message.getMessage())
        }
        return items
    }

    // MARK: Private

    private func generateMovementAnimations(entity: ModelEntity, duration: Double, isDanmaku: Bool = false) -> AnimationResource {
        let start = Point3D(
            x: entity.position.x,
            y: entity.position.y,
            z: entity.position.z
        )

        let entityWidth = entity.model?.mesh.bounds.extents.x ?? 0.0
        let startXOffset = isDanmaku ? roomBoundaryEnd * 3 : roomBoundaryEnd
        let end = Point3D(
            x: start.x - Double(startXOffset + entityWidth * 2),
            y: start.y,
            z: start.z
        )

        let linear = FromToByAnimation<Transform>(
            from: .init(scale: .init(repeating: 1), translation: simd_float(start.vector)),
            to: .init(scale: .init(repeating: 1), translation: simd_float(end.vector)),
            duration: duration,
            timing: .linear,
            bindTarget: .transform
        )

        let animation = try! AnimationResource
            .generate(with: linear)

        return animation
    }

    private func fetchChannelHistory(token: String, channelId: String, limit: Int) async throws -> SlackChannelHistoryResponse? {
        var url = URL(string: "https://slack.com/api/conversations.history")!
        let params: [URLQueryItem] = [
            URLQueryItem(name: "channel", value: channelId),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        url.append(queryItems: params)

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError
        }

        return try JSONDecoder().decode(SlackChannelHistoryResponse.self, from: data)
    }
}

struct SlackMessageToDisplay: Equatable {
    var text: String = ""
    var color: UIColor = .white
    var type: SlackMessageCustomType = .regular

    static func make(slackMessage: SlackMessage) -> Self {
        let message = slackMessage.getMessage().first ?? ""
        let components = message.components(separatedBy: ",")
        if components.count == 3 {
            return SlackMessageToDisplay(
                text: components[0],
                color: UIColor(hex: components[1]) ?? .white,
                type: SlackMessageCustomType.make(oneLetter: components[2])
            )
        }
        return SlackMessageToDisplay()
    }
}

enum SlackMessageCustomType: String {
    case regular
    case danmaku

    static func make(oneLetter: String) -> Self {
        switch oneLetter {
        case "R":
            return .regular
        case "D":
            return .danmaku
        default:
            return .regular
        }
    }
}

// MARK: - API

enum APIError: Error {
    case networkError
    case unknown

    var title: String {
        switch self {
        case .networkError:
            return "network error"
        case .unknown:
            return "unknown error"
        }
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: 0.8)
    }
}

// MARK: - Slack

struct SlackChannelHistoryResponse: Decodable {
    let ok: Bool
    let messages: [SlackMessage]
}

struct SlackMessage: Decodable, Equatable {
    // note: SlackMessage's id is "ts". https://api.slack.com/methods/chat.delete
    static func == (lhs: SlackMessage, rhs: SlackMessage) -> Bool {
        lhs.ts == rhs.ts
    }

    let bot_id: String?
    let type: String
    let text: String
    let user: String
    let ts: String
    let app_id: String?
    let blocks: [SlackBlock]
    let team: String
    let bot_profile: SlackBotProfile?

    func getMessage() -> [String] {
        var items: [String] = []
        for block in blocks {
            for blockElement in block.elements {
                for textElement in blockElement.elements {
                    items.append(textElement.text)
                }
            }
        }
        return items
    }
}

struct SlackBlock: Decodable {
    let type: String
    let block_id: String
    let elements: [SlackBlockElement]
}

struct SlackBlockElement: Decodable {
    let type: String
    let elements: [SlackTextElement]
}

struct SlackTextElement: Decodable {
    let type: String
    let text: String
}

struct SlackBotProfile: Decodable {
    let id: String
    let app_id: String
    let name: String
    let icons: SlackBotIcons
    let deleted: Bool
    let updated: TimeInterval
    let team_id: String
}

struct SlackBotIcons: Decodable {
    let image_36: String
    let image_48: String
    let image_72: String
}
