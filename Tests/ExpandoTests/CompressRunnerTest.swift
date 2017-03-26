//
//  CompressRunnerTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest
@testable import Expando

class CompressRunnerTest: XCTestCase {

  func testEmptyData() {
    let runner = CompressRunner(Data())
    XCTAssertNil(runner)
  }

  func testDataCounts() {
    let data = Data([UInt8.max, UInt8.min, UInt8.allZeros, 0b11010100])
    let runner = CompressRunner(data)!
    if let counts = try? runner.compress() {
      XCTAssertEqual(counts, [0, 8, 18, 1, 1, 1, 1, 2])
    } else {
      XCTFail("Unable to compress data.")
    }
  }

  func testStaticRunner() {
    let data = Data([UInt8.max, UInt8.min, UInt8.allZeros, 0b11010100])
    let runner = CompressRunner(data)!
    if let compressed = try? runner.compress(),
      let staticCompressed = try? CompressRunner.compress(data) {
      XCTAssertEqual(compressed, staticCompressed)
    } else {
      XCTFail("Unable to compress data.")
    }
  }
  
}
