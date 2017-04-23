//
//  main.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation
import CommandLineKit

// MARK: - command line arguments
fileprivate enum CommandlineFlags: String {
  case inputFileFlag = "-i"
  case outputFileFlag = "-o"
  case compressFlag = "-c"
  case reconstructFlag = "-u"
}

fileprivate func writeToStdError(_ str: String) {
  let handle = FileHandle.standardError

  if let data = (str + "\n").data(using: String.Encoding.utf8, allowLossyConversion: false) {
    handle.write(data)
  }
}

fileprivate func printUsageAndExit() {
  let programName = CommandLine.arguments[0]
  let err = String(format: "Usage: \(programName)"
    + " [\(CommandlineFlags.compressFlag.rawValue) | \(CommandlineFlags.reconstructFlag.rawValue)]"
    + " \(CommandlineFlags.inputFileFlag.rawValue) inputFile"
    + " \(CommandlineFlags.outputFileFlag.rawValue) outputFile")
  writeToStdError(err)
  exit(EX_USAGE)
}

fileprivate func printInvalidInputFileAndExit(file: String) {
  let err = String(format: "Could not read file path at \(file)")
  writeToStdError(err)
  exit(EXIT_FAILURE)
}

fileprivate func printOutputFileExistsWarning(file: String) {
  let err = String(format: "Warning: overwriting file at path \(file)")
  writeToStdError(err)
}

func validateOpts(_ opts: [String: [String]]) -> Bool {
  if 1 != opts[CommandlineFlags.inputFileFlag.rawValue]?.count {
    return false
  }

  if 1 != opts[CommandlineFlags.outputFileFlag.rawValue]?.count {
    return false
  }

  // Exactly one of -c and -u must be specified, and should have no arguments
  switch (opts[CommandlineFlags.compressFlag.rawValue], opts[CommandlineFlags.reconstructFlag.rawValue]) {
  case let (.some(a), nil),
       let (nil, .some(a)):
    return a.isEmpty
  default:
    return false
  }
}

func getOpts(_ arguments: [String]) -> [String: [String]] {
  var opts = [String: [String]]()
  var key: String?
  for arg in arguments {
    if arg.hasPrefix("-") {
      opts[arg] = []
      key = arg
      continue
    }
    if let k = key {
      opts[k]!.append(arg)
    } else {
      printUsageAndExit()
    }
  }
  return opts
}

// MARK: - I/O
fileprivate enum ZipMode {
  case compress, reconstruct

  var flag: CommandlineFlags {
    switch self {
    case .compress: return CommandlineFlags.compressFlag
    case .reconstruct: return CommandlineFlags.reconstructFlag
    }
  }
}

// MARK: - Process CommandLine

let compressOpt = BoolOption(shortFlag: "c", longFlag: "inflate",
                             required: false, helpMessage: "blah blah help on compression")
let reconstructOpt = BoolOption(shortFlag: "r", longFlag: "deflate",
                                required: false, helpMessage: "blah blah help on reconstruction")
let inputFileOpt = MultiStringOption(shortFlag: "i", longFlag: "input",
                                     required: true, helpMessage: "blah blah help on input file(s)")
let outputFileOpt = StringOption(shortFlag: "o", longFlag: "output",
                                 required: true, helpMessage: "blah blah help on output file(s)")

enum CLIValidationError: Error {
  case missingOperation, duplicateOperation
  case missingInput, invalidInputFile(String)
}

let fileManager = FileManager.default

func validateCommandLineOpts() throws {
  guard let inputFiles = inputFileOpt.value else {
    throw CLIValidationError.missingInput
  }

  // exactly one of compress and reconstruct must be specified
  switch (compressOpt.value, reconstructOpt.value) {
  case (false, false):
    throw CLIValidationError.missingOperation
  case (true, true):
    throw CLIValidationError.duplicateOperation
  default:
    break
  }

  // validate input file path(s)
  for inputFile in inputFiles {
    let fullPath = NSString(string: inputFile).expandingTildeInPath
    if !fileManager.isReadableFile(atPath: fullPath) {
      throw CLIValidationError.invalidInputFile(inputFile)
    }
  }

}

let cli = CommandLineKit.CommandLine()
cli.addOptions(compressOpt, reconstructOpt, inputFileOpt, outputFileOpt)
do {
  try cli.parse(strict: true)
  try validateCommandLineOpts()
} catch {
  cli.printUsage(error)
  exit(EX_USAGE)
}

print("compressOpt: \(String(describing: compressOpt.value))")
print("reconstructOpt: \(String(describing: reconstructOpt.value))")
print("inputFileOpt: \(String(describing: inputFileOpt.value))")
print("outputFileOpt: \(String(describing: outputFileOpt.value))")
