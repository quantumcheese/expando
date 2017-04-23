//
//  Compression.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

fileprivate enum Bits: UInt8 {
  case one = 1
  case maxNumberOfBits = 8
}

public enum Compression {

  enum BoundaryConditions: Error {
    case emptyData
    case byteIndexTooHigh(index: Int)
    case bitIndexTooHigh(index: UInt8)
  }

  public static func startsWithZeroBit(bytes: Data) throws -> Bool {
    if bytes.isEmpty {
      throw BoundaryConditions.emptyData
    }

    return 0 == (bytes[0] & Bits.one.rawValue)
  }

  public static func consecutiveBitsFromPosition(bytes: Data,
                                                 byteIndex startingByteIndex: Int,
                                                 bitIndex startingBitIndex: UInt8) throws -> Int {
    if bytes.isEmpty {
      throw BoundaryConditions.emptyData
    }
    if bytes.count <= startingByteIndex {
      throw BoundaryConditions.byteIndexTooHigh(index: startingByteIndex)
    }
    if Bits.maxNumberOfBits.rawValue <= startingBitIndex {
      throw BoundaryConditions.bitIndexTooHigh(index: startingBitIndex)
    }

    var byteIndex = startingByteIndex
    var bitIndex = startingBitIndex
    // get the bit at the current position
    var byte = bytes[byteIndex]
    let bitmask = (byte >> bitIndex) & Bits.one.rawValue

    var count = 0
    while bitmask == ((byte >> bitIndex) & Bits.one.rawValue) {
      count += 1
      bitIndex += 1
      if Bits.maxNumberOfBits.rawValue == bitIndex {
        bitIndex = 0
        byteIndex += 1
        if byteIndex == bytes.count {
          break
        }
        byte = bytes[byteIndex]
      }
    }

    return count
  }
}
