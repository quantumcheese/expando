//
//  ArchiveTest.swift
//  Inflato
//
//  Created by Yosef Brown on 2017-04-14.
//
//

import XCTest
@testable import Inflato

class ArchiveTest: XCTestCase {

  func testRetrieveContents_notAdded_nil() {
    let archive = Archive()

    XCTAssertNil(archive.contentsOfFile("joey"))
  }

  func assertArchiveContainsFile(archive: Archive, file: String, contents: FileContents) {
    if let archiveContents = archive.contentsOfFile(file) {
      XCTAssertEqual(archiveContents, contents)
    } else {
      XCTFail("Archive did not contain contents of file \(file)")
    }
  }

  func testRetriveContents_singleFile_retrieved() {
    let filename = "joe.txt"
    let contents = [0, 4, 7, 3, 9]

    var archive = Archive()
    archive.archiveFile(filename, withContents: contents)

    assertArchiveContainsFile(archive: archive, file: filename, contents: contents)
  }

  func testRetriveContents_multipleFiles_retrieved() {
    let filename1 = "joe.txt"
    let contents1 = [0, 4, 7, 3, 9]
    let filename2 = "jerry"
    let contents2 = [1, 1, 2, 3, 5, 8, 13, 21, 34]

    var archive = Archive()
    archive.archiveFile(filename1, withContents: contents1)
    archive.archiveFile(filename2, withContents: contents2)

    assertArchiveContainsFile(archive: archive, file: filename1, contents: contents1)
    assertArchiveContainsFile(archive: archive, file: filename2, contents: contents2)
  }

  func testInitializeFromData_nonDictionary_nil() {
    let data = NSKeyedArchiver.archivedData(withRootObject: ["pharoah", "moo"])

    let archive = Archive(data)

    XCTAssertNil(archive)
  }

  func testInitializeFromData_badZeroInContents_nil() {
    let data = NSKeyedArchiver.archivedData(withRootObject: ["pharoah": [3, 0], "moo": [0, 1, 3, 4]])

    let archive = Archive(data)

    XCTAssertNil(archive)
  }

  func testInitializeFromData_goodData_init() {
    let data = NSKeyedArchiver.archivedData(withRootObject: ["pharoah": [3, 2, 1, 3, 4, 5, 9], "moo": [0, 1, 3, 4]])

    let archive = Archive(data)

    XCTAssertNotNil(archive)
  }

  func testInitializeFromData_fileContents_contained() {
    let root = ["pharoah": [3, 2, 1, 3, 4, 5, 9], "moo": [0, 1, 3, 4]]
    let data = NSKeyedArchiver.archivedData(withRootObject: root)

    if let archive = Archive(data) {
      XCTAssertEqual(root.count, archive.files.count)
      for (file, contents) in root {
        if let archiveContents = archive.contentsOfFile(file) {
          XCTAssertEqual(contents, archiveContents)
        } else {
          XCTFail("Archive did not contain file \(file)")
        }
      }
    } else {
      XCTFail("Unable to reconstitute archive")
    }
  }

  func testToData_initialize_equal() {
    let filename1 = "joe.txt"
    let contents1 = [0, 4, 7, 3, 9]
    let filename2 = "jerry"
    let contents2 = [1, 1, 2, 3, 5, 8, 13, 21, 34]

    var archive1 = Archive()
    archive1.archiveFile(filename1, withContents: contents1)
    archive1.archiveFile(filename2, withContents: contents2)
    let data = archive1.data

    if let archive2 = Archive(data) {
      assertArchiveContainsFile(archive: archive2, file: filename1, contents: contents1)
      assertArchiveContainsFile(archive: archive2, file: filename2, contents: contents2)
    } else {
      XCTFail("Unable to reconstitute archive")
    }
  }
}
