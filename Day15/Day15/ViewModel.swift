import SwiftUI
import Observation

@Observable
class ViewModel {

    var selectedType: SelectionType = .guitars
    var isShowing: Bool = false

    enum SelectionType: String, Identifiable, CaseIterable {
        case guitars = "guitars"
        case televisions = "televisions"
        case shoes = "shoes"

        var id: String {
            return rawValue
        }

        var url: URL {
            switch self {
            case .guitars:
                return URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/stratocaster/fender_stratocaster.usdz")!
            case .televisions:
                return URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/retrotv/tv_retro.usdz")!
            case .shoes:
                return URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/nike-air-force/sneaker_airforce.usdz")!
            }
        }

        var title: String {
            switch self {
            case .guitars:
                return "Guitars"
            case .televisions:
                return "Televisions"
            case .shoes:
                return "Shoes"
            }
        }

        var imageName: String {
            switch self {
            case .guitars:
                return "guitars"
            case .televisions:
                return "tv"
            case .shoes:
                return "shoe"
            }
        }
    }
}
