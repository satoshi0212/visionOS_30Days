import SwiftUI
import Observation

@Observable
class ViewModel {

    var messages: [SlackMessage] = []
    private let token = "xoxp-xxxxx"
    private var task: Task<Void, Error>?

    // fetch data at 1 second intervals
    func fetchData(channelId: String, limit: Int = 1) async throws {
        guard task == nil else { return }

        task = Task {
            do {
                while true {
                    print("fetchData task called.")
                    if let response = try await self.fetchSlackChannelHistory(token: token, channelId: channelId, limit: limit) {
                        self.messages = response.messages
                    }
                    try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
                }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }

    func stopFetchingData() {
        task?.cancel()
        task = nil
    }

    private func fetchSlackChannelHistory(token: String, channelId: String, limit: Int) async throws -> SlackChannelHistoryResponse? {
        var url = URL(string: "https://slack.com/api/conversations.history")!
        let params: [URLQueryItem] = [
            URLQueryItem(name: "channel", value: channelId),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        url.append(queryItems: params)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.networkError
        }

        return try JSONDecoder().decode(SlackChannelHistoryResponse.self, from: data)
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

// MARK: - Slack Data

struct SlackChannelHistoryResponse: Decodable {
    let ok: Bool
    let messages: [SlackMessage]
}

struct SlackMessage: Decodable {
    let bot_id: String?
    let type: String
    let text: String
    let user: String
    let ts: String
    let app_id: String?
    let blocks: [SlackBlock]
    let team: String
    let bot_profile: SlackBotProfile?
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
