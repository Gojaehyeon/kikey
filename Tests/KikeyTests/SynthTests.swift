import XCTest
import AVFoundation
@testable import Kikey

final class SynthTests: XCTestCase {
    func testMakeBufferHasExpectedFrameCount() {
        let buffer = Synth.makeBuffer(seconds: 0.1)
        XCTAssertEqual(buffer.frameLength, AVAudioFrameCount(0.1 * Synth.sampleRate))
    }

    func testKeycodeSemitonesIsBounded() {
        for code: UInt16 in 0...255 {
            let s = Synth.keycodeSemitones(code, range: 6.0)
            XCTAssertGreaterThanOrEqual(s, -6.0)
            XCTAssertLessThanOrEqual(s, 6.0)
        }
    }

    func testSemitonesToRatioIsMonotonic() {
        let a = Synth.semitonesToRatio(0)
        let b = Synth.semitonesToRatio(12)
        XCTAssertEqual(a, 1.0, accuracy: 0.0001)
        XCTAssertEqual(b, 2.0, accuracy: 0.0001)
    }
}
