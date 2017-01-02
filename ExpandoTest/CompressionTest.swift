//
//  CompressionTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest

class CompressionTest: XCTestCase {

    func testCountZeros() {
        var binary = Data([UInt8.allZeros])
        var count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 8)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 3)
        XCTAssertEqual(count, 5)


        binary = Data([0b00000010, UInt8.allZeros])
        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 1)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 2)
        XCTAssertEqual(count, 14)
    }

    func testCountOnes() {
        var binary = Data([UInt8.max])
        var count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 8)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 3)
        XCTAssertEqual(count, 5)


        binary = Data([0b11111101, UInt8.max])
        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 1)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 2)
        XCTAssertEqual(count, 14)
    }

    func testFromLaterByte() {
        let binary = Data([UInt8.allZeros, 0b11111101, UInt8.max])
        let count = try! Compression.countFromPosition(bytes: binary, byteIndex: 1, bitIndex: 4)
        XCTAssertEqual(count, 12)
    }

    func testEmptyBytes() {
        let binary = Data()
        do {
            _ = try Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
            XCTFail("Didn't throw")
        } catch Compression.BoundaryConditions.emptyData() {
            // expected exception
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

    func testEndOfBytes() {
        let binary = Data([UInt8.max])
        do {
            _ = try Compression.countFromPosition(bytes: binary, byteIndex: 1, bitIndex: 0)
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
            _ = try Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 43)
            XCTFail("Didn't throw")
        } catch Compression.BoundaryConditions.bitIndexTooHigh(index: let e) {
            XCTAssertEqual(e, 43)
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

    func teststartsWithZeroBit() {
        var binary = Data([UInt8.allZeros])
        var startsWithZeroBit = try! Compression.startsWithZeroBit(bytes: binary)
        XCTAssertTrue(startsWithZeroBit)

        binary = Data([0b10000000, UInt8.max])
        startsWithZeroBit = try! Compression.startsWithZeroBit(bytes: binary)
        XCTAssertTrue(startsWithZeroBit)
    }

    func testNotStartWithZero() {
        var binary = Data([UInt8.max])
        var startsWithZeroBit = try! Compression.startsWithZeroBit(bytes: binary)
        XCTAssertFalse(startsWithZeroBit)

        binary = Data([0b000000001, UInt8.allZeros])
        startsWithZeroBit = try! Compression.startsWithZeroBit(bytes: binary)
        XCTAssertFalse(startsWithZeroBit)
    }

    func testEmptyDataExceptsWithZero() {
        let binary = Data()
        do {
            _ = try Compression.startsWithZeroBit(bytes: binary)
            XCTFail("Didn't throw")
        } catch Compression.BoundaryConditions.emptyData() {
            // expected exception
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

}
