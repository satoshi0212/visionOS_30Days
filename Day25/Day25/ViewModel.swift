import RealityKit
import Observation

@Observable
class ViewModel {

    private var contentEntity = Entity()

    var leftListItems = ["カリム・ベンゼマ / Karim Benzema",
                         "エンゴロ・カンテ / N'Golo Kanté",
                         "ロベルト・フィルミーノ /Roberto Firmino",
                         "リヤド・マフレズ / Riyad Mahrez"]
    var rightListItems = ["クリスティアーノ・ロナウド / Cristiano Ronaldo"]

    var isHomeTargeted = false
    var isOtherTargeted = false

    func setupContentEntity() -> Entity {
        return contentEntity
    }
}
