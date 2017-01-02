//
//  CompressTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest

class CompressTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCountZeros() {
        var binary = [UInt8.allZeros]
        var count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 8)

        count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 3)
        XCTAssertEqual(count, 5)


        binary = [0b00000010, UInt8.allZeros]
        count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 1)

        count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 2)
        XCTAssertEqual(count, 14)
    }

    func testCountOnes() {
        var binary = [UInt8.max]
        var count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 8)

        count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 3)
        XCTAssertEqual(count, 5)


        binary = [0b11111101, UInt8.max]
        count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        XCTAssertEqual(count, 1)

        count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 2)
        XCTAssertEqual(count, 14)
    }

    func testFromLaterByte() {
        let binary = [UInt8.allZeros, 0b11111101, UInt8.max]
        let count = try! Compress.countFromPosition(bytes: binary, byteIndex: 1, bitIndex: 4)
        XCTAssertEqual(count, 12)
    }

    func testEmptyBytes() {
        let binary: Array<UInt8> = []
        do {
            _ = try Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        } catch Compress.BoundaryConditions.emptyData() {
            // expected exception
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

    func testEndOfBytes() {
        let binary = [UInt8.max]
        do {
            _ = try Compress.countFromPosition(bytes: binary, byteIndex: 1, bitIndex: 0)
        } catch Compress.BoundaryConditions.byteIndexTooHigh(index: let e) {
            XCTAssertEqual(e, 1)
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

    func testTooManyBits() {
        let binary = [UInt8.allZeros]
        do {
            _ = try Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 43)
        } catch Compress.BoundaryConditions.bitIndexTooHigh(index: let e) {
            XCTAssertEqual(e, 43)
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

    func testStartsWithZero() {
        var binary = [UInt8.allZeros]
        var startsWithZero = try! Compress.startsWithZero(bytes: binary)
        XCTAssertTrue(startsWithZero)

        binary = [0b10000000, UInt8.max]
        startsWithZero = try! Compress.startsWithZero(bytes: binary)
        XCTAssertTrue(startsWithZero)
    }

    func testNotStartWithZero() {
        var binary = [UInt8.max]
        var startsWithZero = try! Compress.startsWithZero(bytes: binary)
        XCTAssertFalse(startsWithZero)

        binary = [0b000000001, UInt8.allZeros]
        startsWithZero = try! Compress.startsWithZero(bytes: binary)
        XCTAssertFalse(startsWithZero)
    }

    func testEmptyDataExceptsWithZero() {
        let binary: Array<UInt8> = []
        do {
            _ = try Compress.startsWithZero(bytes: binary)
        } catch Compress.BoundaryConditions.emptyData() {
            // expected exception
        } catch let e {
            XCTFail("Caught unexpected exception \(e)")
        }
    }

 /*   func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
*/
}
