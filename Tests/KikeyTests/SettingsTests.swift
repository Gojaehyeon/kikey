import XCTest
@testable import Kikey

final class SettingsTests: XCTestCase {
    func testVolumeLevelGainsAreOrdered() {
        XCTAssertLessThan(VolumeLevel.soft.gain, VolumeLevel.balanced.gain)
        XCTAssertLessThan(VolumeLevel.balanced.gain, VolumeLevel.loud.gain)
    }

    func testVolumeLevelLabelsExist() {
        for level in VolumeLevel.allCases {
            XCTAssertFalse(level.label.isEmpty)
        }
    }

    func testSharedSettingsLoadsDefaults() {
        let settings = Settings.shared
        XCTAssertNotNil(settings.soundPackID)
        XCTAssertTrue(SoundPackRegistry.all.contains { $0.id == settings.soundPackID })
    }
}
