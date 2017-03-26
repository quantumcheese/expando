//
//  CompressionTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest
@testable import Expando

class CompressionTest: XCTestCase {

  func tryCompressingConsecutiveBits(_ bytes: Data, byteIndex: Int, bitIndex: UInt8) -> Int? {
    if let count = try? Compression.consecutiveBitsFromPosition(bytes: bytes,
                                                                byteIndex: byteIndex,
                                                                bitIndex: bitIndex) {
      return count
    } else {
      XCTFail("Unable to count bits from index.")
      return nil
    }
  }

  func tryStartsWithZero(bytes: Data) -> Bool? {
    if let startsWith = try? Compression.startsWithZeroBit(bytes: bytes) {
      return startsWith
    } else {
      XCTFail("Unable to determine if data starts with 0; data is probably empty.")
      return nil
    }
  }

  func testCountZeros() {
    var binary = Data([UInt8.allZeros])
    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 0) {
      XCTAssertEqual(count, 8)
    }

    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 3) {
      XCTAssertEqual(count, 5)
    }

    binary = Data([0b00000010, UInt8.allZeros])
    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 0) {
      XCTAssertEqual(count, 1)
    }

    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 2) {
      XCTAssertEqual(count, 14)
    }
  }

  func testCountOnes() {
    var binary = Data([UInt8.max])
    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 0) {
      XCTAssertEqual(count, 8)
    }

    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 3) {
      XCTAssertEqual(count, 5)
    }

    binary = Data([0b11111101, UInt8.max])
    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 0) {
      XCTAssertEqual(count, 1)
    }

    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 0, bitIndex: 2) {
      XCTAssertEqual(count, 14)
    }
  }

  func testFromLaterByte() {
    let binary = Data([UInt8.allZeros, 0b11111101, UInt8.max])
    if let count = tryCompressingConsecutiveBits(binary, byteIndex: 1, bitIndex: 4) {
      XCTAssertEqual(count, 12)
    }
  }

  func testEmptyBytes() {
    let binary = Data()
    do {
      _ = try Compression.consecutiveBitsFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
      XCTFail("Didn't throw")
    } catch Compression.BoundaryConditions.emptyData {
      // expected exception
    } catch let e {
      XCTFail("Caught unexpected exception \(e)")
    }
  }

  func testEndOfBytes() {
    let binary = Data([UInt8.max])
    do {
      _ = try Compression.consecutiveBitsFromPosition(bytes: binary, byteIndex: 1, bitIndex: 0)
      XCTFail("Didn't throw")
    } catch Compression.BoundaryConditions.byteIndexTooHigh(index: let e) {
      XCTAssertEqual(e, 1)
    } catch let e {
      XCTFail("Caught unexpected exception \(e)")
    }
  }

  func testTooManyBits() {
    let binary = Data([UInt8.allZeros])
    do {
      _ = try Compression.consecutiveBitsFromPosition(bytes: binary, byteIndex: 0, bitIndex: 43)
      XCTFail("Didn't throw")
    } catch Compression.BoundaryConditions.bitIndexTooHigh(index: let e) {
      XCTAssertEqual(e, 43)
    } catch let e {
      XCTFail("Caught unexpected exception \(e)")
    }
  }

  func teststartsWithZeroBit() {
    var binary = Data([UInt8.allZeros])
    if let startsWithZeroBit = tryStartsWithZero(bytes: binary) {
      XCTAssertTrue(startsWithZeroBit)
    }

    binary = Data([0b10000000, UInt8.max])
    if let startsWithZeroBit = tryStartsWithZero(bytes: binary) {
      XCTAssertTrue(startsWithZeroBit)
    }
  }

  func testNotStartWithZero() {
    var binary = Data([UInt8.max])
    if let startsWithZeroBit = tryStartsWithZero(bytes: binary) {
      XCTAssertFalse(startsWithZeroBit)
    }

    binary = Data([0b000000001, UInt8.allZeros])
    if let startsWithZeroBit = tryStartsWithZero(bytes: binary) {
      XCTAssertFalse(startsWithZeroBit)
    }
  }

  func testEmptyDataExceptsWithZero() {
    let binary = Data()
    do {
      _ = try Compression.startsWithZeroBit(bytes: binary)
      XCTFail("Didn't throw")
    } catch Compression.BoundaryConditions.emptyData {
      // expected exception
    } catch let e {
      XCTFail("Caught unexpected exception \(e)")
    }
  }

}
