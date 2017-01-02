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
        var binary = [UInt8.allZeros]
        var count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 8)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 3)
        XCTAssertEqual(count, 5)


        binary = [0b00000010, UInt8.allZeros]
        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 1)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 2)
        XCTAssertEqual(count, 14)
    }

    func testCountOnes() {
        var binary = [UInt8.max]
        var count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 8)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 3)
        XCTAssertEqual(count, 5)


        binary = [0b11111101, UInt8.max]
        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 1)

        count = try! Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 2)
        XCTAssertEqual(count, 14)
    }

    func testFromLaterByte() {
        let binary = [UInt8.allZeros, 0b11111101, UInt8.max]
        let count = try! Compression.countFromPosition(bytes: binary, byteIndex: 1, bitIndex: 4)
        XCTAssertEqual(count, 12)
    }

    func testEmptyBytes() {
        let binary: Array<UInt8> = []
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
        let binary = [UInt8.max]
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
        let binary = [UInt8.allZeros]
        do {
            _ = try Compression.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 43)
            XCTFail("Didn't throw")
        } catch Compression.BoundaryConditions.bitIndexTooHigh(index: let e) {
            XCTAssertEqual(e, 43)
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

    func testStartsWithZero() {
        var binary = [UInt8.allZeros]
        var startsWithZero = try! Compression.startsWithZero(bytes: binary)
        XCTAssertTrue(startsWithZero)

        binary = [0b10000000, UInt8.max]
        startsWithZero = try! Compression.startsWithZero(bytes: binary)
        XCTAssertTrue(startsWithZero)
    }

    func testNotStartWithZero() {
        var binary = [UInt8.max]
        var startsWithZero = try! Compression.startsWithZero(bytes: binary)
        XCTAssertFalse(startsWithZero)

        binary = [0b000000001, UInt8.allZeros]
        startsWithZero = try! Compression.startsWithZero(bytes: binary)
        XCTAssertFalse(startsWithZero)
    }

    func testEmptyDataExceptsWithZero() {
        let binary: Array<UInt8> = []
        do {
            _ = try Compression.startsWithZero(bytes: binary)
            XCTFail("Didn't throw")
        } catch Compression.BoundaryConditions.emptyData() {
            // expected exception
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

}
