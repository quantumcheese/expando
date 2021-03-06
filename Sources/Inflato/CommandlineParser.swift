//
//  CommandlineParser.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-01-29.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

public enum CommandlineParser {
  public typealias ParsingRules = [String: ParsingRule]
  public typealias ParsedArguments = [String: [String]]

  public enum Arity {
    case flag         // n == 0
    case singleArg    // n == 1
    case multipleArgs // n >= 1
    case nArgs(Int)   // n == m
  }

  public struct ParsingRule {
    let required: Bool
    let arity: Arity

    init(arity: Arity) {
      self.init(arity: arity, required: true)
    }

    init(arity: Arity, required: Bool) {
      self.arity = arity
      self.required = required
    }
  }

  public enum ParseError: Error {
    case unexpectedFlag(flag: String)
    case duplicateFlag(flag: String)
    case missingArgument(flag: String)
    case tooManyArguments(flag: String)
    case tooFewArguments(flag: String)
    case argumentWithoutFlag(argument: String)
    case missingFlag(flag: String)
  }

  private static func isFlag(_ arg: String) -> Bool {
    return arg.hasPrefix("-")
  }

  private static func validateRule(flag: String, rule: CommandlineParser.ParsingRule, args: [String]) throws {
    switch (rule.arity, args.count) {
    case let (.flag, c) where 0 < c:
      throw ParseError.tooManyArguments(flag: flag)

    case (.singleArg, let x) where 1 < x:
      throw ParseError.tooManyArguments(flag: flag)

    case (.singleArg, 0),
         (.multipleArgs, 0):
      throw ParseError.missingArgument(flag: flag)

    case let (.nArgs(n), c) where n < c:
      throw ParseError.tooManyArguments(flag: flag)
    case let (.nArgs(n), c) where c < n:
      throw ParseError.tooFewArguments(flag: flag)

    default:
      // Valid!  Do not throw.
      break
    }
  }

  private static func validateRequiredFlags(rules: ParsingRules, arguments: ParsedArguments) throws {
    for (flag, rule) in rules where rule.required && nil == arguments[flag] {
      throw ParseError.missingFlag(flag: flag)
    }
  }

  public static func parse(_ args: [String], rules: ParsingRules) throws -> ParsedArguments {
    var parsedOpts: [String: [String]] = [:]
    var key: String?
    // skip empty strings
    for arg in args where !arg.isEmpty {
      if isFlag(arg) {
        // check if this flag has a parsing rule
        if nil == rules[arg] {
          throw ParseError.unexpectedFlag(flag: arg)
        }
        // check if we've encountered this flag before; repeats not allowed
        if nil != parsedOpts[arg] {
          throw ParseError.duplicateFlag(flag: arg)
        }
        // check if the old flag (if any) was valid
        if let key = key,
          let parsedArgs = parsedOpts[key] {
          try validateRule(flag: key, rule: rules[key]!, args: parsedArgs)
        }
        parsedOpts[arg] = []
        key = arg
        continue
      } else if let k = key {
        parsedOpts[k]!.append(arg)
      } else {
        throw ParseError.argumentWithoutFlag(argument: arg)
      }
    }

    if let key = key,
      let parsedArgs = parsedOpts[key] {
      try validateRule(flag: key, rule: rules[key]!, args: parsedArgs)
    }

    try validateRequiredFlags(rules: rules, arguments: parsedOpts)

    return parsedOpts
  }
}
