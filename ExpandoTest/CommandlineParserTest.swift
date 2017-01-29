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

    // MARK: Single Flag processing

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
    

    func testEmptyCommandline() {
        let parsed = try! CommandlineParser.parse([], rules: rules)

        XCTAssertTrue(parsed.isEmpty)
    }

    func testFlagWithoutParsingRule() {
        parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.unexpectedFlag(flag: "-a"))
    }

    func testDuplicateFlag() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
        parseSingleFlagForException(commandLine: ["-a", "-a"], expectedException: CommandlineParser.ParseError.duplicateFlag(flag: "-a"))
    }

    func testFlagParsingRule() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
        parseSingleFlagForArguments(flag: "-a", expectedArguments: [])
    }

    func testSingleParsingRule_noArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)
        parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.missingArgument(flag: "-a"))
    }

    func testSingleParsingRule_singleArg() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)

        parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
    }

    func testMultipleArgs_noArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)
        parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.missingArgument(flag: "-a"))
    }

    func testMultipleArgs_singleArg() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)

        parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
    }

    func testMultipleArgs_multipleArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .multipleArgs)

        parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple", "banana"])
    }

    func test0NArgs_noArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
        parseSingleFlagForArguments(flag: "-a", expectedArguments: [])
    }

    func test0NArgs_arg() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
        parseSingleFlagForException(commandLine: ["-a", "apple"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
    }

    func test0NArgs_args() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(0))
        parseSingleFlagForException(commandLine: ["-a", "apple", "banana", "cherry"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
    }

    func test1NArgs_noArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
        parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
    }

    func test1NArgs_arg() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
        parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple"])
    }

    func test1NArgs_args() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(1))
        parseSingleFlagForException(commandLine: ["-a", "apple", "banana", "cherry"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
    }

    func test3NArgs_noArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
        parseSingleFlagForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
    }

    func test3NArgs_arg() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
        parseSingleFlagForException(commandLine: ["-a", "apple"], expectedException: CommandlineParser.ParseError.tooFewArguments(flag: "-a"))
    }

    func test3NArgs_3args() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
        parseSingleFlagForArguments(flag: "-a", expectedArguments: ["apple", "banana", "cherry"])
    }

    func test3NArgs_moreArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .nArgs(3))
        parseSingleFlagForException(commandLine: ["-a", "apple", "banana", "cherry", "date", "elderberry"], expectedException: CommandlineParser.ParseError.tooManyArguments(flag: "-a"))
    }

    // MARK:

}
