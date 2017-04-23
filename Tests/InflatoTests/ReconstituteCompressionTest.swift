//
//  ReconstituteCompressionTest.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest
@testable import Inflato

class ReconstituteCompressionTest: XCTestCase {

  func testDataStartingWithZeros() {
    let binary = Data([UInt8.allZeros, UInt8.allZeros, UInt8.allZeros])
    if let count = try? Compression.consecutiveBitsFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0),
      let data = try? Reconstitution.reconstitute([count]) {
      XCTAssertEqual(data, binary)
    } else {
      XCTFail("Unable to regain data starting with zeros")
    }
  }

}
