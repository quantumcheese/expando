//
//  Archive.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-04-23.
//
//

import Foundation

public typealias FileContents = [Int]

protocol Archive {
  func contentsOfFile(_ file: String) -> FileContents?
  mutating func archiveFile(_ file: String, withContents contents: FileContents)
}

protocol ReadWriteArchive: Archive {

}
