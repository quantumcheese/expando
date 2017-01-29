//
//  CommandlineParser.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-29.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

//protocol UsagePrinter {
//    func printUsageAndExit() -> Never
//}
//
class CommandlineParser {
//    static var delegate: UsagePrinter?

    enum ParseError : Error, Equatable {
        case unexpectedFlag(flag: String)
        case duplicateFlag(flag: String)
        case missingArgument(flag: String)
            case tooManyArguments(flag: String)
            case tooFewArguments(flag: String)
        case argumentWithoutFlag(argument: String)

        static func ==(lhs: ParseError, rhs: ParseError) -> Bool {
            switch (lhs, rhs) {
            case let (.unexpectedFlag(lf), .unexpectedFlag(rf)),
                 let (.duplicateFlag(lf), .duplicateFlag(rf)),
                 let (.missingArgument(lf), .missingArgument(rf)),
                 let (.tooManyArguments(lf), .tooManyArguments(rf)),
                 let (.tooFewArguments(lf), .tooFewArguments(rf)),
                 let (.argumentWithoutFlag(lf), .argumentWithoutFlag(rf)):
                return lf == rf
            default:
                return false
            }
        }
    }

    struct ParsingRule {
        enum Arity {
            case flag         // n == 0
            case singleArg    // n == 1
            case multipleArgs // n >= 1
            case nArgs(UInt)   // n == m
        }
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

    private static func isFlag(_ arg: String) -> Bool {
        return arg.hasPrefix("-")
    }

    private static func checkRule(rule: CommandlineParser.ParsingRule, args: [String]) throws {

    }

    static func parse(_ args: [String], rules: [String: ParsingRule]) throws -> [String: [String]] {
        var parsedOpts: [String: [String]] = [:]
        var key: String?
        for arg in args {
            if isFlag(arg) {
                // check if this flag has a parsing rule
                if nil == rules[arg] {
                    throw ParseError.unexpectedFlag(flag: arg)
//                    delegate?.printUsageAndExit()
                }
                // check if we've encountered this flag before; repeats not allowed
                if nil != parsedOpts[arg] {
                    throw ParseError.duplicateFlag(flag: arg)
//                    delegate?.printUsageAndExit()
                }
                // check if the old flag (if any) was valid
                if let key = key,
                    let parsedArgs = parsedOpts[key] {
                    checkRule(rule: rules[arg]!, args: parsedArgs)
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
        return parsedOpts
    }
}
