import Foundation

struct Video: Identifiable, Hashable, Codable {

    let id: Int
    let url: URL
    let title: String
}
