import SwiftUI
import Observation

@Observable
class ViewModel {

    var titleText: String = ""
    var isTitleFinished: Bool = false
    var finalTitle: String = "第11話 1文字ずつタイトルを表示"
}
