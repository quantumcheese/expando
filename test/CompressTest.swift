//
//  CompressTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest

class CompressTest: XCTestCase {
    var compressor : Compress? = nil

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.compressor = Compress()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testZeros() {
        var binary: [UInt8] = [0b00000000]
        var data = Data(bytes: binary)
        var count = compressor!.countInitialZeros(data)
        XCTAssertEqual(count, 8)

        binary = [0b01000000]
        data = Data(bytes: binary)
        count = compressor!.countInitialZeros(data)
        XCTAssertEqual(count, 1)

        binary = [0b10000000]
        data = Data(bytes: binary)
        count = compressor!.countInitialZeros(data)
        XCTAssertEqual(count, 0)

    }

 /*   func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
*/
}
