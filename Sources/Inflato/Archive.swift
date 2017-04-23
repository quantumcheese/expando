//
//  Archive.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-04-14.
//
//

import Foundation

public typealias FileContents = [Int]
private typealias ArchiveMap = [String: FileContents]

fileprivate func validateUnarchivedData(_ data: ArchiveMap) -> Bool {
  // The only possible place for a 0 is in the initial position, if the file began with a 1
  for contents in data.values {
    let zeros = contents.filter { $0 == 0 }
    if (1 == zeros.count && 0 != contents[0]) || 1 < zeros.count {
      return false
    }
  }
  return true
}

struct Archive {

  private var fileArchive: ArchiveMap

  var files: [String] {
    return Array(self.fileArchive.keys)
  }

  var data: Data {
    return NSKeyedArchiver.archivedData(withRootObject:fileArchive)
  }

  init() {
    self.fileArchive = ArchiveMap()
  }

  // failable initializer
  init?(_ data: Data) {
    guard let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: data) as? ArchiveMap else {
      return nil
    }
    if !validateUnarchivedData(unarchivedData) {
      return nil
    }

    self.fileArchive = unarchivedData
  }

  mutating func archiveFile(_ file: String, withContents contents: FileContents) {
    fileArchive[file] = contents
  }

  func contentsOfFile(_ file: String) -> FileContents? {
    return fileArchive[file]
  }

}
