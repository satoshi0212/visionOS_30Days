import Foundation
import Combine
import GroupActivities
import CoreTransferable
import UIKit

struct VideoWatchingActivity: GroupActivity, Transferable {

    let video: Video

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .watchTogether
        metadata.title = video.title
        metadata.supportsContinuationOnTV = true
        return metadata
    }
}
