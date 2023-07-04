import SwiftUI
import RealityKit
import Observation

@Observable
class Day7ViewModel {

    private var contentEntity = Entity()
    private let token = ""
    private let channel = "#bots"

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func getTargetEntity(name: String) -> Entity? {
        return contentEntity.children.first { $0.name == name}
    }

    func addCube(name: String) -> Entity {
        guard
            let texture1 = try? TextureResource.load(named: "Slack_icon")
        else {
            fatalError("Unable to load texture.")
        }

        var material1 = SimpleMaterial()
        material1.color = .init(tint: .white ,texture: .init(texture1))

        let entity = ModelEntity(
            mesh: .generateBox(size: 0.5, cornerRadius: 0),
            materials: [material1],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.5)),
            mass: 0.0
        )

        entity.name = name
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: SIMD3<Float>(repeating: 0.5))], isStatic: true))
        entity.position = SIMD3(x: 0, y: 1, z: -2)

        contentEntity.addChild(entity)

        return entity
    }

    func postToSlack(message: String) async throws {
        var request = URLRequest(url: URL(string: "https://slack.com/api/chat.postMessage")!)
        request.httpMethod = "POST"
        request.httpBody = "token=\(token)&channel=\(channel)&text=\(message)".data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError
        }
        print(data)
    }
}

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
