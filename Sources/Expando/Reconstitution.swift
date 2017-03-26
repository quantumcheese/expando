//
//  Reconstitution.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

public struct Reconstitution {
  public enum BoundaryConditions: Error {
    case emptyCounts
  }

  public enum State {
    case One, Zero

    static prefix func ! (state: State) -> State {
      return .Zero == state ? .One : .Zero
    }

    var bitmask: UInt8 {
      switch self {
      case .One:
        return 1
      case .Zero:
        return 0
      }
    }
  }

  public static func reconstitute(_ counts: [Int]) throws -> Data {
    if counts.isEmpty {
      throw BoundaryConditions.emptyCounts
    }

    var data: [UInt8] = [0]
    var byteIndex = 0
    var bitIndex: UInt8 = 0
    var state = State.Zero
    for var count in counts {
      while count != 0 {
        if 8 == bitIndex {
          data.append(0)
          byteIndex += 1
          bitIndex = 0
        }

        data[byteIndex] = data[byteIndex] | (state.bitmask << bitIndex)
        bitIndex += 1
        count -= 1
      }

      state = !state
    }
    
    return Data(data)
  }
}
