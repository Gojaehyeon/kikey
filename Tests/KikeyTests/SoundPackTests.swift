import XCTest
import AVFoundation
@testable import Kikey

final class SoundPackTests: XCTestCase {
    func testRegistryHasTwelvePacks() {
        XCTAssertEqual(SoundPackRegistry.all.count, 12)
    }

    func testAllPackIDsAreUnique() {
        let ids = SoundPackRegistry.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testEveryPackProducesAudibleKeyDownBuffer() {
        for pack in SoundPackRegistry.all {
            let buffer = pack.bufferForKeyDown(keyCode: 0, randomizePitch: false)
            XCTAssertGreaterThan(buffer.frameLength, 0, "\(pack.id) returned empty buffer")
            let data = buffer.floatChannelData![0]
            var peak: Float = 0
            for i in 0..<Int(buffer.frameLength) {
                peak = max(peak, abs(data[i]))
            }
            XCTAssertGreaterThan(peak, 0.01, "\(pack.id) is silent (peak=\(peak))")
            XCTAssertLessThanOrEqual(peak, 1.0, "\(pack.id) clips (peak=\(peak))")
        }
    }

    func testRegistryLookupByID() {
        XCTAssertNotNil(SoundPackRegistry.pack(id: "cat"))
        XCTAssertNotNil(SoundPackRegistry.pack(id: "mech"))
        XCTAssertNil(SoundPackRegistry.pack(id: "does-not-exist"))
    }
}
