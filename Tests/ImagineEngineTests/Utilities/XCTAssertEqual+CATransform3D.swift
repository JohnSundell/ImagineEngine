import Foundation
import XCTest
import QuartzCore

func XCTAssertEqual(_ transformA: CATransform3D,
                    _ transformB: CATransform3D,
                    file: StaticString = #file,
                    line: UInt = #line) {
    let valueA = NSValue(caTransform3D: transformA)
    let valueB = NSValue(caTransform3D: transformB)
    XCTAssertEqual(valueA, valueB, file: file, line: line)
}
