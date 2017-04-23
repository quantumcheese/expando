//
//  ReconstitutionTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest
@testable import Expando

class ReconstitutionTest: XCTestCase {

  func reconstitute(bitCounts: FileContents) -> Data? {
    if let data = try? Reconstitution.reconstitute(bitCounts) {
      return data
    } else {
      XCTFail("Unable to reconstitute bit-counts.")
      return nil
    }
  }

  func testEmptyCounts() {
    let counts = FileContents()
    do {
      _ = try Reconstitution.reconstitute(counts)
      XCTFail("Didn't throw")
    } catch Reconstitution.BoundaryConditions.emptyCounts() {
      // expected
    } catch let e {
      XCTFail("Unexpected exception \(e)")
    }
  }

  func testZeroCount() {
    let counts = [0]
    if let data = reconstitute(bitCounts:counts) {
      XCTAssertEqual(data, Data([0]))
    }
  }

  func testStartWithZero() {
    let counts = [1, 1]
    if let data = reconstitute(bitCounts:counts) {
      XCTAssertEqual(data, Data([0b00000010]))
    }
  }

  func testStartsWithOne() {
    let counts = [0, 2, 3, 4]
    if let data = reconstitute(bitCounts:counts) {
      XCTAssertEqual(data, Data([0b11100011, 0b0000001]))
    }
  }
}
