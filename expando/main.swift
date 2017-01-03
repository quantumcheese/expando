//
//  main.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

let INPUT_FILE_FLAG = "-i"
let OUTPUT_FILE_FLAG = "-o"
let COMPRESS_FLAG = "-c"
let RECONSTRUCT_FLAG = "-u"

fileprivate func writeToStdError(_ str: String) {
    let handle = FileHandle.standardError

    if let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false) {
        handle.write(data)
    }
}

fileprivate func printUsageAndExit() {
    let programName = CommandLine.arguments[0]
    let err = String(format: "Usage: \(programName) [\(COMPRESS_FLAG) | \(RECONSTRUCT_FLAG)] \(INPUT_FILE_FLAG) inputFile \(OUTPUT_FILE_FLAG) outputFile")
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
    if 1 != opts[INPUT_FILE_FLAG]?.count {
        return false
    }

    if 1 != opts[OUTPUT_FILE_FLAG]?.count {
        return false
    }

    // Exactly one of -c and -u must be specified, and should have no arguments
    switch (opts[COMPRESS_FLAG], opts[RECONSTRUCT_FLAG]) {
    case (.some(let a), nil)
    , (nil, .some(let a)):
        if !a.isEmpty {
            return false
        }
        break
    default:
        return false
    }

    return true
}

func getOpts(_ arguments: Array<String>) -> [String: [String]] {
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

enum ZipMode {
    case Compress, Reconstruct

    var flag: String {
        switch (self) {
        case .Compress: return COMPRESS_FLAG
        case .Reconstruct: return RECONSTRUCT_FLAG
        }
    }
}

var compressionMode = ZipMode.Compress
var inputFile: String
var outputFile: String

// process commandline args and decide whether to "compress" (expand) or "decompress" (restore)
var args = CommandLine.arguments
args.remove(at: 0)
let opts = getOpts(args)
if !validateOpts(opts) {
    printUsageAndExit()
}

// determine ZipMode

if nil != opts[ZipMode.Compress.flag] {
    compressionMode = ZipMode.Compress
} else if nil != opts[ZipMode.Reconstruct.flag] {
    compressionMode = ZipMode.Reconstruct
} else {
    // this case should be impossible, since we already validated the 'opts' dict
    printUsageAndExit()
}

let fileManager = FileManager.default


// validate input file path
inputFile = NSString(string: opts[INPUT_FILE_FLAG]![0]).expandingTildeInPath
if !fileManager.isReadableFile(atPath: inputFile) {
    printInvalidInputFileAndExit(file: inputFile)
}


// warn on output file already existing
outputFile = NSString(string: opts[OUTPUT_FILE_FLAG]![0]).expandingTildeInPath
//let outputURL = URL(fileURLWithPath: outputFile, relativeTo: nil)
//let absPath = outputURL.absoluteString
if fileManager.fileExists(atPath: outputFile) {
    printOutputFileExistsWarning(file: outputFile)
}

fileprivate func compressFile(_ filePath: String) -> [Int] {
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: inputFile))
        return try CompressRunner.compress(data)
    } catch let e {
        writeToStdError(String(format: "Error reading and compressing file: \(e)"))
        exit(EXIT_FAILURE)
    }
}

fileprivate func writeCompressedFile(file: [Int], outputFile: String) {
    let nsFile = file as NSArray
    nsFile.write(toFile: outputFile, atomically: false)
}

fileprivate func readCompressedFile(_ filePath: String) -> Data {
    let nsCounts = NSArray(contentsOfFile: filePath)
    let counts = nsCounts as! Array<Int>
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

switch (compressionMode) {
case ZipMode.Compress:
    writeCompressedFile(file: compressFile(inputFile), outputFile: outputFile)
    break
case ZipMode.Reconstruct:
    writeReconstructedFile(data: readCompressedFile(inputFile), outputFile: outputFile)
    break
}

