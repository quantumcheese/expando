//
//  CompressRunner.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

struct CompressRunner {
    let data: Data

    init?(_ data: Data) {
        if (data.isEmpty) {
            return nil
        }
        self.data = data
    }

    static func compress(_ data: Data) throws -> [Int] {
        return CompressRunner(data)?.compress() ?? []
    }

    func compress() -> [Int] {
        var counts: Array<Int> = []
        if (try! !Compression.startsWithZeroBit(bytes: self.data)) {
            counts.append(0)
        }

        var byteIndex = Int.allZeros
        var bitIndex = UInt8.allZeros

        while (byteIndex < self.data.count) {
            let count = try! Compression.countFromPosition(bytes: self.data, byteIndex: byteIndex, bitIndex: bitIndex)
            counts.append(count)

            bitIndex = bitIndex.advanced(by: count)
            if (8 <= bitIndex) {
                byteIndex += Int(bitIndex / 8)
                bitIndex %= 8
            }
        }

        return counts
    }
}
