//
//  CommandlineParserTest.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-29.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import XCTest

let ASYNC_TIMEOUT: TimeInterval = 1.0

class CommandlineParserTest: XCTestCase/*, UsagePrinter */ {
//    func printUsageAndExit() -> Never {
//        if let expectation = expectation {
//            expectation.fulfill()
//        } else {
//            XCTFail("Called printUsage when not expected!")
//        }
//        repeat { } while true
//    }

    var rules: [String: CommandlineParser.ParsingRule] = [:]
    var expectation: XCTestExpectation?

//    override func setUp() {
//        super.setUp()
//        CommandlineParser.delegate = self
//    }

    override func tearDown() {
        rules.removeAll()
        super.tearDown()
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


    func testEmptyCommandline() {
        let parsed = try! CommandlineParser.parse([], rules: rules)

        XCTAssertTrue(parsed.isEmpty)
    }

    func testFlagWithoutParsingRule() {
        parseForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.unexpectedFlag(flag: "-a"))
    }

    func testDuplicateFlag() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)
        parseForException(commandLine: ["-a", "-a"], expectedException: CommandlineParser.ParseError.duplicateFlag(flag: "-a"))
    }

    func testFlagParsingRule() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .flag)

        let parsed = try! CommandlineParser.parse(["-a"], rules: rules)

        XCTAssertEqual(parsed.count, 1)
        if let values = parsed["-a"] {
            XCTAssertTrue(values.isEmpty)
        } else {
            XCTFail("no args returned for flag")
        }
    }

    func testSingleParsingRule_noArgs() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)
        parseForException(commandLine: ["-a"], expectedException: CommandlineParser.ParseError.missingArgument(flag: "-a"))
//        self.expectation = expectation(description: "single arity, no args")
//        rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)
//
//        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
//            _ = CommandlineParser.parse(["-a"], rules: self.rules)
//        }
//
//        waitForExpectations(timeout: ASYNC_TIMEOUT, handler: {error in
//            if let error = error {
//                XCTFail(error.localizedDescription)
//            }
//        })
    }

    func testSingleParsingRule_singleArg() {
        rules["-a"] = CommandlineParser.ParsingRule(arity: .singleArg)

        let parsed = try! CommandlineParser.parse(["-a", "apple"], rules: rules)

        XCTAssertEqual(parsed.count, 1)
        if let values = parsed["-a"] {
            XCTAssertEqual(values.count, 1)
            XCTAssertEqual(values[0], "apple")
        } else {
            XCTFail("no args returned for flag")
        }
    }

    

}
