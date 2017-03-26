//
//  CommandlineParserTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-29.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest
@testable import Expando

class CommandlineParserTest: XCTestCase {
  var rules = CommandlineParser.ParsingRules()

  override func setUp() {
    super.setUp()
    rules.removeAll()
  }

  // MARK: - Helpers

  func assertParsedArgs(_ parsedArgs: CommandlineParser.ParsedArguments, forFlag flag: String, expecting: [String]) {
    guard let args = parsedArgs[flag] else {
      XCTFail("No parsed args for flag \(flag)")
      return
    }

    XCTAssertEqual(args, expecting)
  }

  func parseSingleFlagForArguments(flag: String, expectedArguments: [String]) {
    let commandLine = [flag] + expectedArguments
    guard let parsed = try? CommandlineParser.parse(commandLine, rules: self.rules) else {
      XCTFail("Parsing attempt threw.")
      return
    }

    XCTAssertEqual(parsed.count, 1)
    assertParsedArgs(parsed, forFlag: flag, expecting: expectedArguments)
  }

  func parseForException(commandLine: [String], expectedException: CommandlineParser.ParseError) {
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
    guard let parsedOpts = try? CommandlineParser.parse([], rules: self.rules) else {
      XCTFail("Parsing attempt threw.")
      return
    }

    XCTAssertTrue(parsedOpts.isEmpty)
  }

  func testFlag_noRule_unexpectedFlag() {
    parseForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.unexpectedFlag(flag: "-a"))
  }

  func testDuplicateFlag_duplicateFlag() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    parseForException(commandLine: ["-a", "-a"],
                      expectedException: CommandlineParser.ParseError.duplicateFlag(flag: "-a"))
  }

  func testFlag_noArgs_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: [])
  }

  func testFlag_3args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    parseForException(commandLine: ["-a", "apple", "banana"],
                      expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func testSingle_noArgs_missingArg() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)
    parseForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.missingArgument(flag: "-a"))
  }

  func testSingle_singleArg_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
  }

  func testMultipleArgs_0Args_missingArg() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)
    parseForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.missingArgument(flag: "-a"))
  }

  func testMultipleArgs_singleArg_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
  }

  func testMultipleArgs_multipleArgs_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple", "banana"])
  }

  func test0NArgs_0Args_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
    parseSingleFlagForArguments(flag: "-a", expectedArguments: [])
  }

  func test0NArgs_1Arg_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
    parseForException(commandLine: ["-a", "apple"],
                      expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func test0NArgs_3Args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
    parseForException(commandLine: ["-a", "apple", "banana", "cherry"],
                      expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func test1NArgs_0Args_tooFew() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
    parseForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
  }

  func test1NArgs_1Arg_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
  }

  func test1NArgs_3Args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
    parseForException(commandLine: ["-a", "apple", "banana", "cherry"],
                      expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  func test3NArgs_0Args_tooFew() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
  }

  func test3NArgs_1Arg_tooFew() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseForException(commandLine: ["-a", "apple"], expectedException:
      CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
  }

  func test3NArgs_3Args_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple", "banana", "cherry"])
  }

  func test3NArgs_5Args_tooMany() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
    parseForException(commandLine: ["-a", "apple", "banana", "cherry", "date", "elderberry"],
                      expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
  }

  // MARK: - Multiple Flags

  func test2Flags_2Rules_parsed() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    rules["-b"] = CommandlineParser.ParsingRule(arity: .flag)
    let commandLine = ["-a", "-b"]

    guard let parsedOpts = try? CommandlineParser.parse(commandLine, rules: self.rules) else {
      XCTFail("Parsing attempt threw.")
      return
    }

    XCTAssertEqual(parsedOpts.count, 2)
    assertParsedArgs(parsedOpts, forFlag: "-a", expecting: [])
    assertParsedArgs(parsedOpts, forFlag: "-b", expecting: [])
  }

  func test2Flags_1Rule_parsed() {
    rules["-b"] = CommandlineParser.ParsingRule(arity: .flag)
    let commandLine = ["-a", "-b"]

    parseForException(commandLine: commandLine,
                      expectedException: CommandlineParser.ParseError.unexpectedFlag(flag: "-a"))
  }

  func testMixedRules_parse() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    rules["-b"] = CommandlineParser.ParsingRule(arity: .singleArg)
    rules["-c"] = CommandlineParser.ParsingRule(arity: .nArgs(4))
    let commandLine = ["-c", "tulip", "rose", "petunia", "purgatory", "-a", "-b", "glyph"]

    guard let parsedOpts = try? CommandlineParser.parse(commandLine, rules: self.rules) else {
      XCTFail("Parsing attempt threw.")
      return
    }

    XCTAssertEqual(parsedOpts.count, 3)
    assertParsedArgs(parsedOpts, forFlag: "-a", expecting: [])
    assertParsedArgs(parsedOpts, forFlag: "-b", expecting: ["glyph"])
    assertParsedArgs(parsedOpts, forFlag: "-c", expecting: ["tulip", "rose", "petunia", "purgatory"])
  }

  func testMixedRules_tooFew() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
    rules["-b"] = CommandlineParser.ParsingRule(arity: .singleArg)
    rules["-c"] = CommandlineParser.ParsingRule(arity: .nArgs(4))
    let commandLine = ["-c", "tulip", "rose", "petunia", "purgatory", "-a", "-b"]

    parseForException(commandLine: commandLine,
                      expectedException: CommandlineParser.ParseError.missingArgument(flag: "-b"))
  }

  // MARK: - required and non-required flags

  func testNonRequiredFlag() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag, required: false)

    guard let parsedOpts = try? CommandlineParser.parse([], rules: self.rules) else {
      XCTFail("Parsing attempt threw.")
      return
    }

    XCTAssertTrue(parsedOpts.isEmpty)
  }

  func testMixedRequiredFlags() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag, required: false)
    rules["-b"] = CommandlineParser.ParsingRule(arity: .singleArg)

    guard let parsedOpts = try? CommandlineParser.parse(["-b", "banana"], rules: self.rules) else {
      XCTFail("Parsing attempt threw.")
      return
    }

    XCTAssertEqual(parsedOpts.count, 1)
    assertParsedArgs(parsedOpts, forFlag: "-b", expecting: ["banana"])
  }

  func testRequiredFlag() {
    rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)

    parseForException(commandLine: [], expectedException: CommandlineParser.ParseError.missingFlag(flag: "-a"))

    rules["-b"] = CommandlineParser.ParsingRule(arity: .singleArg)
    parseForException(commandLine: ["-b", "banana"],
                      expectedException: CommandlineParser.ParseError.missingFlag(flag: "-a"))
  }
  
}
