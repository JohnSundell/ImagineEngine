/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2018
 *  See LICENSE file for license
 */

import XCTest
@testable import ImagineEngine

final class SpriteSheetTests: XCTestCase {
    func testGeneratingFramesFromSingleDimensionalSpriteSheet() {
        let sheet = SpriteSheet(textureNamed: "Sheet", frameCount: 5, rowCount: 1)

        let frame1 = sheet.frame(at: 0)
        let frame4 = sheet.frame(at: 3)

        XCTAssertEqual(frame1.contentRect, Rect(x: 0, y: 0, width: 0.2, height: 1))
        XCTAssertEqual(frame4.contentRect, Rect(x: 0.6, y: 0, width: 0.2, height: 1))
    }

    func testGeneratingFramesFromTwoDimensionalSpriteSheet() {
        let sheet = SpriteSheet(textureNamed: "Sheet", frameCount: 8, rowCount: 2)

        let frame1 = sheet.frame(at: 0)
        let frame4 = sheet.frame(at: 3)
        let frame7 = sheet.frame(at: 6)

        #if os(macOS)
        XCTAssertEqual(frame1.contentRect, Rect(x: 0, y: 0.5, width: 0.25, height: 0.5))
        XCTAssertEqual(frame4.contentRect, Rect(x: 0.75, y: 0.5, width: 0.25, height: 0.5))
        XCTAssertEqual(frame7.contentRect, Rect(x: 0.5, y: 0, width: 0.25, height: 0.5))
        #else
        XCTAssertEqual(frame1.contentRect, Rect(x: 0, y: 0, width: 0.25, height: 0.5))
        XCTAssertEqual(frame4.contentRect, Rect(x: 0.75, y: 0, width: 0.25, height: 0.5))
        XCTAssertEqual(frame7.contentRect, Rect(x: 0.5, y: 0.5, width: 0.25, height: 0.5))
        #endif
    }

    func testGeneratingFramesFromSlicedSpriteSheet() {
        let sheet = SpriteSheet(textureNamed: "Sheet", frameCount: 16, rowCount: 4)
        let slice = sheet.slice(from: Coordinate(x: 2, y: 1)...Coordinate(x: 3, y: 2))

        let frame1 = slice.frame(at: 0)
        let frame4 = slice.frame(at: 3)

        #if os(macOS)
        XCTAssertEqual(frame1.contentRect, Rect(x: 0.5, y: 0.5, width: 0.25, height: 0.25))
        XCTAssertEqual(frame4.contentRect, Rect(x: 0.75, y: 0.25, width: 0.25, height: 0.25))
        #else
        XCTAssertEqual(frame1.contentRect, Rect(x: 0.5, y: 0.25, width: 0.25, height: 0.25))
        XCTAssertEqual(frame4.contentRect, Rect(x: 0.75, y: 0.5, width: 0.25, height: 0.25))
        #endif
    }
}
