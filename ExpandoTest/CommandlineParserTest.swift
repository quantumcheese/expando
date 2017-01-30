//
//  CommandlineParserTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-29.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest

class CommandlineParserTest: XCTestCase {
  var rules = CommandlineParser.ParsingRules()

  override func setUp() {
    super.setUp()
    rules.removeAll()
  }

  // MARK: - Single Flag helpers

  func parseSingleFlagForArguments(flag: String, expectedArguments: [String]) {
    let commandLine = [flag] + expectedArguments
    guard let parsed = try? CommandlineParser.parse(commandLine, rules: self.rules) else {
      XCTFail("Parsing attempt threw.")
      return
    }

    XCTAssertEqual(parsed.count, 1)
    if let args = parsed[flag] {
      XCTAssertEqual(args, expectedArguments)
    } else {
      XCTFail("no args parsed for flag \(flag)")
    }
  }

  func parseSingleFlagForException(commandLine: [String], expectedException: CommandlineParser.ParseError) {
    do {
      _ = try CommandlineParser.parse(commandLine, rules: self.rules)
      XCTFail("Did not throw")
    } catch let e as CommandlineParser.ParseError {
      XCTAssertEqual(e, expectedException)
    } catch let e {
      XCTFail("Caught unexpected exception \(e)")
    }
  }


  // MARK: - Single Flag tests

  func testEmptyCommandline_noRules_parsed() {
    let parsed = try! CommandlineParser.parse([], rules: rules)

    XCTAssertTrue(parsed.isEmpty)
  }

  func testFlag_noRule_unexpectedFlag() {
    parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.unexpectedFlag(flag: "-a"))
  }

  func testDuplicateFlag_duplicateFlag() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    parseSingleFlagForException(commandLine: ["-a", "-a"], expectedException: CommandlineParser.ParseError.duplicateFlag(flag: "-a"))
  }

  func testFlag_noArgs_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: [])
  }

  func testFlag_3args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    parseSingleFlagForException(commandLine: ["-a", "apple", "banana"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func testSingle_noArgs_missingArg() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)
    parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.missingArgument(flag: "-a"))
  }

  func testSingle_singleArg_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
  }

  func testMultipleArgs_noArgs_missingArg() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)
    parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.missingArgument(flag: "-a"))
  }

  func testMultipleArgs_singleArg_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
  }

  func testMultipleArgs_multipleArgs_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple", "banana"])
  }

  func test0NArgs_0args_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
    parseSingleFlagForArguments(flag: "-a", expectedArguments: [])
  }

  func test0NArgs_1arg_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
    parseSingleFlagForException(commandLine: ["-a", "apple"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func test0NArgs_3args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
    parseSingleFlagForException(commandLine: ["-a", "apple", "banana", "cherry"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func test1NArgs_0args_tooFew() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
    parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
  }

  func test1NArgs_1arg_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
  }

  func test1NArgs_3args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
    parseSingleFlagForException(commandLine: ["-a", "apple", "banana", "cherry"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func test3NArgs_0args_tooFew() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
  }

  func test3NArgs_1arg_tooFew() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseSingleFlagForException(commandLine: ["-a", "apple"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
  }

  func test3NArgs_3args_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple", "banana", "cherry"])
  }

  func test3NArgs_5args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseSingleFlagForException(commandLine: ["-a", "apple", "banana", "cherry", "date", "elderberry"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  // MARK: - Multiple Flags

  func test2Rules() {

  }

}
