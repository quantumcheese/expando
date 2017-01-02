//
//  ReconstituteCompressionTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest

class ReconstituteCompressionTest: XCTestCase {

    func testDataStartingWithZeros() {
        let binary = [UInt8.allZeros, UInt8.allZeros, UInt8.allZeros]
        let count = try! Compress.countFromPosition(bytes: binary, byteIndex: 0, bitIndex: 0)
        let data = try! Reconstitution.reconstitute([count])
        XCTAssertEqual(data, Data(binary))
    }
}