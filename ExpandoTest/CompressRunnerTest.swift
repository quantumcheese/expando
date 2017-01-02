//
//  CompressRunnerTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest

class CompressRunnerTest: XCTestCase {

    func testEmptyData() {
        let runner = CompressRunner(Data())
        XCTAssertNil(runner)
    }

    func testDataCounts() {
        let data = Data([UInt8.max, UInt8.min, UInt8.allZeros, 0b11010100])
        let runner = CompressRunner(data)!
        let counts = runner.compress()
        XCTAssertEqual(counts, [0, 8, 18, 1, 1, 1, 1, 2])
    }

    func testStaticRunner() {
        let data = Data([UInt8.max, UInt8.min, UInt8.allZeros, 0b11010100])
        let runner = CompressRunner(data)!
        let compressed = runner.compress()
        let staticCompressed = try! CompressRunner.compress(data)
        XCTAssertEqual(compressed, staticCompressed)
    }

}
