import Foundation

enum SoundPackRegistry {
    static let all: [SoundPack] = [
        CatPack(),
        MechPack(),
        TopreePack(),
        TypewriterPack(),
        PopPack(),
        DropPack(),
        BellPack(),
        HeartPack(),
        ClickPack(),
        makeTwinklePack(),
        makeOdeToJoyPack(),
        makeCanonPack(),
    ]

    static var defaultPack: SoundPack { all[0] }

    static func pack(id: String) -> SoundPack? {
        all.first(where: { $0.id == id })
    }
}
