//
//  Reconstitution.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

public enum Reconstitution {
  public enum BoundaryConditions: Error {
    case emptyCounts
  }

  private enum State {
    case one, zero

    static prefix func ! (state: State) -> State {
      return .zero == state ? .one : .zero
    }

    var bitmask: UInt8 {
      switch self {
      case .one:
        return 1
      case .zero:
        return 0
      }
    }
  }

  public static func reconstitute(_ counts: FileContents) throws -> Data {
    if counts.isEmpty {
      throw BoundaryConditions.emptyCounts
    }

    var data: [UInt8] = [0]
    var byteIndex = 0
    var bitIndex: UInt8 = 0
    var state = State.zero
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
