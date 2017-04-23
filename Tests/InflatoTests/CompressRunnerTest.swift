//
//  CompressRunnerTest.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest
@testable import Inflato

class CompressRunnerTest: XCTestCase {

  func testEmptyData_nil() {
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
}
