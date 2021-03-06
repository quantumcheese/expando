//
//  main.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

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
  exit(EXIT_FAILURE)
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

fileprivate enum ZipMode {
  case compress, reconstruct

  var flag: CommandlineFlags {
    switch self {
    case .compress: return CommandlineFlags.compressFlag
    case .reconstruct: return CommandlineFlags.reconstructFlag
    }
  }
}

fileprivate var compressionMode = ZipMode.compress
fileprivate var inputFile: String
fileprivate var outputFile: String

// process commandline args and decide whether to "compress" (expand) or "decompress" (restore)
var args = CommandLine.arguments
args.remove(at: 0)
let opts = getOpts(args)
if !validateOpts(opts) {
  printUsageAndExit()
}

// determine ZipMode

if nil != opts[ZipMode.compress.flag.rawValue] {
  compressionMode = ZipMode.compress
} else if nil != opts[ZipMode.reconstruct.flag.rawValue] {
  compressionMode = ZipMode.reconstruct
} else {
  // this case should be impossible, since we already validated the 'opts' dict
  printUsageAndExit()
}

let fileManager = FileManager.default

// validate input file path
inputFile = NSString(string: opts[CommandlineFlags.inputFileFlag.rawValue]![0]).expandingTildeInPath
if !fileManager.isReadableFile(atPath: inputFile) {
  printInvalidInputFileAndExit(file: inputFile)
}

// warn on output file already existing
outputFile = NSString(string: opts[CommandlineFlags.outputFileFlag.rawValue]![0]).expandingTildeInPath
//let outputURL = URL(fileURLWithPath: outputFile, relativeTo: nil)
//let absPath = outputURL.absoluteString
if fileManager.fileExists(atPath: outputFile) {
  printOutputFileExistsWarning(file: outputFile)
}

fileprivate func compressFile(_ filePath: String) -> FileContents {
  do {
    let data = try Data(contentsOf: URL(fileURLWithPath: inputFile))
    return try CompressRunner(data)?.compress() ?? []
  } catch let e {
    writeToStdError(String(format: "Error reading and compressing file: \(e)"))
    exit(EXIT_FAILURE)
  }
}

fileprivate func writeCompressedFile(file: FileContents, outputFile: String) {
  let nsFile = file as NSArray
  nsFile.write(toFile: outputFile, atomically: false)
}

fileprivate func readCompressedFile(_ filePath: String) -> Data {
  guard let counts = NSArray(contentsOfFile: filePath) as? FileContents else {
    writeToStdError(String(format: "Error reading contents of file: \(filePath)"))
    exit(EXIT_FAILURE)
  }

  do {
    let data = try Reconstitution.reconstitute(counts)
    return data
  } catch let e {
    writeToStdError(String(format: "Error decompressing file: \(e)"))
    exit(EXIT_FAILURE)
  }
}

fileprivate func writeReconstructedFile(data: Data, outputFile: String) {
  do {
    try data.write(to: URL(fileURLWithPath: outputFile))
  } catch let e {
    writeToStdError(String(format: "Error writing file: \(e)"))
    exit(EXIT_FAILURE)
  }
}

switch compressionMode {
case ZipMode.compress:
  writeCompressedFile(file: compressFile(inputFile), outputFile: outputFile)
  break
case ZipMode.reconstruct:
  writeReconstructedFile(data: readCompressedFile(inputFile), outputFile: outputFile)
  break
}
