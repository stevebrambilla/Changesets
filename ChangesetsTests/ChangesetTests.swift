//
//  MatchingTests.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-25.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import XCTest
@testable import Changesets

class ChangesetTests: XCTestCase {
	func testMatchableChangeset() {
		let source = [
			MatchableValue(name: "A", rev: 0), // 0
			MatchableValue(name: "B", rev: 0), // 1
			MatchableValue(name: "C", rev: 0), // 2
			MatchableValue(name: "D", rev: 0), // 3
			MatchableValue(name: "H", rev: 0), // 4
			MatchableValue(name: "I", rev: 0), // 5
		]
		let dest = [
			MatchableValue(name: "B", rev: 0), // 0
			MatchableValue(name: "C", rev: 0), // 1
			MatchableValue(name: "D", rev: 1), // 2
			MatchableValue(name: "F", rev: 0), // 3
			MatchableValue(name: "G", rev: 0), // 4
			MatchableValue(name: "H", rev: 0), // 5
			MatchableValue(name: "I", rev: 1), // 6
			MatchableValue(name: "K", rev: 0), // 7
		]

		let changeset = source.changesetTo(dest)

		var updatedGenerator = changeset.updated.generate()
		var deletedGenerator = changeset.deleted.generate()
		var insertedGenerator = changeset.inserted.generate()

		// Delete 'A', source index
		let aRange: Range<Int>! = deletedGenerator.next()
		XCTAssert(aRange != nil)
		XCTAssertEqual(aRange.startIndex, 0)
		XCTAssertEqual(aRange.endIndex, 1)

		// Update 'D', source index
		let dRange: Range<Int>! = updatedGenerator.next()
		XCTAssert(dRange != nil)
		XCTAssertEqual(dRange.startIndex, 3)
		XCTAssertEqual(dRange.endIndex, 4)

		// Insert 'F' and 'G', dest index
		let fgRange: Range<Int>! = insertedGenerator.next()
		XCTAssert(fgRange != nil)
		XCTAssertEqual(fgRange.startIndex, 3)
		XCTAssertEqual(fgRange.endIndex, 5)

		// Update 'I', source index
		let iRange: Range<Int>! = updatedGenerator.next()
		XCTAssert(iRange != nil)
		XCTAssertEqual(iRange.startIndex, 5)
		XCTAssertEqual(iRange.endIndex, 6)

		// Insert 'K', dest index
		let kRange: Range<Int>! = insertedGenerator.next()
		XCTAssert(kRange != nil)
		XCTAssertEqual(kRange.startIndex, 7)
		XCTAssertEqual(kRange.endIndex, 8)

		// All generators should be exhausted
		XCTAssert(updatedGenerator.next() == nil)
		XCTAssert(deletedGenerator.next() == nil)
		XCTAssert(insertedGenerator.next() == nil)

		// There were 6 indexes changes in total
		XCTAssertEqual(changeset.changedIndexCount, 6)
	}

	func testEquatableChangeset() {
		let source = [
			EquatableValue(name: "A", rev: 0), // 0
			EquatableValue(name: "B", rev: 0), // 1
			EquatableValue(name: "C", rev: 0), // 2
			EquatableValue(name: "D", rev: 0), // 3
			EquatableValue(name: "H", rev: 0), // 4
			EquatableValue(name: "I", rev: 0), // 5
		]
		let dest = [
			EquatableValue(name: "B", rev: 0), // 0
			EquatableValue(name: "C", rev: 0), // 1
			EquatableValue(name: "D", rev: 1), // 2
			EquatableValue(name: "F", rev: 0), // 3
			EquatableValue(name: "G", rev: 0), // 4
			EquatableValue(name: "H", rev: 0), // 5
			EquatableValue(name: "I", rev: 1), // 6
			EquatableValue(name: "K", rev: 0), // 7
		]

		let changeset = source.changesetTo(dest)

		// No updated ranges when relying on Equatable for matching
		XCTAssertEqual(changeset.updated.count, 0)

		// --- Deletions
		var deletedGenerator = changeset.deleted.generate()

		// Delete 'A'
		let aRange: Range<Int>! = deletedGenerator.next()
		XCTAssert(aRange != nil)
		XCTAssertEqual(aRange.startIndex, 0)
		XCTAssertEqual(aRange.endIndex, 1)

		// Delete 'D' (was updated)
		let dRange: Range<Int>! = deletedGenerator.next()
		XCTAssert(dRange != nil)
		XCTAssertEqual(dRange.startIndex, 3)
		XCTAssertEqual(dRange.endIndex, 4)

		// Delete 'I' (was updated)
		let iRange: Range<Int>! = deletedGenerator.next()
		XCTAssert(iRange != nil)
		XCTAssertEqual(iRange.startIndex, 5)
		XCTAssertEqual(iRange.endIndex, 6)

		// --- Inserts
		var insertedGenerator = changeset.inserted.generate()

		// Insert 'D' (was updated), 'F', and 'G'
		let dfgRange: Range<Int>! = insertedGenerator.next()
		XCTAssert(dfgRange != nil)
		XCTAssertEqual(dfgRange.startIndex, 2)
		XCTAssertEqual(dfgRange.endIndex, 5)

		// Insert 'I' (was updated), and 'K'
		let ikRange: Range<Int>! = insertedGenerator.next()
		XCTAssert(ikRange != nil)
		XCTAssertEqual(ikRange.startIndex, 6)
		XCTAssertEqual(ikRange.endIndex, 8)

		XCTAssert(deletedGenerator.next() == nil)
		XCTAssert(insertedGenerator.next() == nil)

		// There were 8 indexes changes in total
		XCTAssertEqual(changeset.changedIndexCount, 8)
	}

	func testReplacementChangeset() {
		let source = [
			EquatableValue(name: "A", rev: 0), // 0
			EquatableValue(name: "B", rev: 0), // 1
			EquatableValue(name: "C", rev: 0), // 2
		]
		let dest = [
			EquatableValue(name: "D", rev: 0), // 0
			EquatableValue(name: "E", rev: 0), // 1
			EquatableValue(name: "F", rev: 0), // 2
			EquatableValue(name: "G", rev: 0), // 3
		]

		let changeset = source.changesetTo(dest)

		XCTAssertEqual(changeset.updated.count, 0)
		XCTAssertEqual(changeset.deleted.count, 1)
		XCTAssertEqual(changeset.inserted.count, 1)

		// Delete All
		let deletedRange = changeset.deleted.first!
		XCTAssertEqual(deletedRange.startIndex, 0)
		XCTAssertEqual(deletedRange.endIndex, 3)

		// Insert All
		let insertedRange = changeset.inserted.first!
		XCTAssertEqual(insertedRange.startIndex, 0)
		XCTAssertEqual(insertedRange.endIndex, 4)

		// This was a full replacement
		XCTAssertTrue(changeset.wasReplaced)
	}

	func testEmptyBeforeChangeset() {
		let source = [EquatableValue]()
		let dest = [
			EquatableValue(name: "D", rev: 0), // 0
			EquatableValue(name: "E", rev: 0), // 1
			EquatableValue(name: "F", rev: 0), // 2
			EquatableValue(name: "G", rev: 0), // 3
		]

		let changeset = source.changesetTo(dest)

		XCTAssertEqual(changeset.updated.count, 0)
		XCTAssertEqual(changeset.deleted.count, 0)
		XCTAssertEqual(changeset.inserted.count, 1)

		// Insert All
		let insertedRange = changeset.inserted.first!
		XCTAssertEqual(insertedRange.startIndex, 0)
		XCTAssertEqual(insertedRange.endIndex, 4)

		// This was a full replacement
		XCTAssertTrue(changeset.wasReplaced)
	}

	func testEmptyAfterChangeset() {
		let source = [
			EquatableValue(name: "A", rev: 0), // 0
			EquatableValue(name: "B", rev: 0), // 1
			EquatableValue(name: "C", rev: 0), // 2
		]
		let dest = [EquatableValue]()

		let changeset = source.changesetTo(dest)

		XCTAssertEqual(changeset.updated.count, 0)
		XCTAssertEqual(changeset.deleted.count, 1)
		XCTAssertEqual(changeset.inserted.count, 0)

		// Delete All
		let deletedRange = changeset.deleted.first!
		XCTAssertEqual(deletedRange.startIndex, 0)
		XCTAssertEqual(deletedRange.endIndex, 3)

		// This was a full replacement
		XCTAssertTrue(changeset.wasReplaced)
	}
}
