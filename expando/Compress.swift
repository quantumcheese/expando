//
//  Compress.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

class Compress {

    func countInitialZeros(_ data: Data) -> Int {
        var count = 0

        data.forEach({(_ byte: UInt8) -> () in
            for i in (0..<8).reversed() {
                let bitmask = (UInt8(1) << UInt8(i))
                let maskedByte = byte & bitmask
                if (0 != maskedByte) {
                    break
                }
                count += 1
            }
        })
        return count
    }
}
