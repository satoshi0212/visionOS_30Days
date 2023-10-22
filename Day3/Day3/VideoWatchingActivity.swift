import Foundation
import GroupActivities
import CoreTransferable

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
