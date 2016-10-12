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

		let changeset = source.changeset(to: dest)

		var updatedIterator = changeset.updated.makeIterator()
		var deletedIterator = changeset.deleted.makeIterator()
		var insertedIterator = changeset.inserted.makeIterator()

		// Delete 'A', source index
		let aRange: CountableRange<Int>! = deletedIterator.next()
		XCTAssert(aRange != nil)
		XCTAssertEqual(aRange.lowerBound, 0)
		XCTAssertEqual(aRange.upperBound, 1)

		// Update 'D', source index
		let dRange: CountableRange<Int>! = updatedIterator.next()
		XCTAssert(dRange != nil)
		XCTAssertEqual(dRange.lowerBound, 3)
		XCTAssertEqual(dRange.upperBound, 4)

		// Insert 'F' and 'G', dest index
		let fgRange: CountableRange<Int>! = insertedIterator.next()
		XCTAssert(fgRange != nil)
		XCTAssertEqual(fgRange.lowerBound, 3)
		XCTAssertEqual(fgRange.upperBound, 5)

		// Update 'I', source index
		let iRange: CountableRange<Int>! = updatedIterator.next()
		XCTAssert(iRange != nil)
		XCTAssertEqual(iRange.lowerBound, 5)
		XCTAssertEqual(iRange.upperBound, 6)

		// Insert 'K', dest index
		let kRange: CountableRange<Int>! = insertedIterator.next()
		XCTAssert(kRange != nil)
		XCTAssertEqual(kRange.lowerBound, 7)
		XCTAssertEqual(kRange.upperBound, 8)

		// All iterators should be exhausted
		XCTAssert(updatedIterator.next() == nil)
		XCTAssert(deletedIterator.next() == nil)
		XCTAssert(insertedIterator.next() == nil)

		// There were 6 indexes changes in total
		XCTAssertEqual(changeset.changedIndexesCount, 6)
		XCTAssertFalse(changeset.wasReplaced)

		// Test tracking of indexes across the changeset.
		XCTAssert(changeset.afterIndexFor(beforeIndex: 0) == nil)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 1) == 0)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 2) == 1)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 3) == 2)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 4) == 5)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 5) == 6)
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

		let changeset = source.changeset(to: dest)

		// No updated ranges when relying on Equatable for matching
		XCTAssertEqual(changeset.updated.count, 0)

		// --- Deletions
		var deletedIterator = changeset.deleted.makeIterator()

		// Delete 'A'
		let aRange: CountableRange<Int>! = deletedIterator.next()
		XCTAssert(aRange != nil)
		XCTAssertEqual(aRange.lowerBound, 0)
		XCTAssertEqual(aRange.upperBound, 1)

		// Delete 'D' (was updated)
		let dRange: CountableRange<Int>! = deletedIterator.next()
		XCTAssert(dRange != nil)
		XCTAssertEqual(dRange.lowerBound, 3)
		XCTAssertEqual(dRange.upperBound, 4)

		// Delete 'I' (was updated)
		let iRange: CountableRange<Int>! = deletedIterator.next()
		XCTAssert(iRange != nil)
		XCTAssertEqual(iRange.lowerBound, 5)
		XCTAssertEqual(iRange.upperBound, 6)

		// --- Inserts
		var insertedIterator = changeset.inserted.makeIterator()

		// Insert 'D' (was updated), 'F', and 'G'
		let dfgRange: CountableRange<Int>! = insertedIterator.next()
		XCTAssert(dfgRange != nil)
		XCTAssertEqual(dfgRange.lowerBound, 2)
		XCTAssertEqual(dfgRange.upperBound, 5)

		// Insert 'I' (was updated), and 'K'
		let ikRange: CountableRange<Int>! = insertedIterator.next()
		XCTAssert(ikRange != nil)
		XCTAssertEqual(ikRange.lowerBound, 6)
		XCTAssertEqual(ikRange.upperBound, 8)

		XCTAssert(deletedIterator.next() == nil)
		XCTAssert(insertedIterator.next() == nil)

		// There were 8 indexes changes in total
		XCTAssertEqual(changeset.changedIndexesCount, 8)
		XCTAssertFalse(changeset.wasReplaced)

		// Test tracking of indexes across the changeset.
		XCTAssert(changeset.afterIndexFor(beforeIndex: 0) == nil)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 1) == 0)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 2) == 1)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 3) == nil) // Cannot track updated indexes without identity
		XCTAssert(changeset.afterIndexFor(beforeIndex: 4) == 5)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 5) == nil) // Same, was updated
	}

	func testUpdateOnlyChangeset() {
		let source = [
			MatchableValue(name: "A", rev: 0), // 0
			MatchableValue(name: "B", rev: 0), // 1
			MatchableValue(name: "C", rev: 0), // 2
		]
		let dest = [
			MatchableValue(name: "A", rev: 0), // 0
			MatchableValue(name: "B", rev: 1), // 1
			MatchableValue(name: "C", rev: 1), // 2
		]

		let changeset = source.changeset(to: dest)

		XCTAssertEqual(changeset.updated.count, 1)
		XCTAssertEqual(changeset.deleted.count, 0)
		XCTAssertEqual(changeset.inserted.count, 0)

		// Update B & C
		let bcRange: CountableRange<Int>! = changeset.updated.first
		XCTAssert(bcRange != nil)
		XCTAssertEqual(bcRange.lowerBound, 1)
		XCTAssertEqual(bcRange.upperBound, 3)

		// There were 2 indexes changes in total
		XCTAssertEqual(changeset.changedIndexesCount, 2)
		XCTAssertFalse(changeset.wasReplaced)

		// Test tracking of indexes across the changeset.
		XCTAssert(changeset.afterIndexFor(beforeIndex: 0) == 0)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 1) == 1)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 2) == 2)
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

		let changeset = source.changeset(to: dest)

		XCTAssertEqual(changeset.updated.count, 0)
		XCTAssertEqual(changeset.deleted.count, 1)
		XCTAssertEqual(changeset.inserted.count, 1)

		// Delete All
		let deletedRange = changeset.deleted.first!
		XCTAssertEqual(deletedRange.lowerBound, 0)
		XCTAssertEqual(deletedRange.upperBound, 3)

		// Insert All
		let insertedRange = changeset.inserted.first!
		XCTAssertEqual(insertedRange.lowerBound, 0)
		XCTAssertEqual(insertedRange.upperBound, 4)

		// This was a full replacement
		XCTAssertTrue(changeset.wasReplaced)

		// Test tracking of indexes across the changeset.
		XCTAssert(changeset.afterIndexFor(beforeIndex: 0) == nil)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 1) == nil)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 2) == nil)
	}

	func testEmptyBeforeChangeset() {
		let source = [EquatableValue]()
		let dest = [
			EquatableValue(name: "D", rev: 0), // 0
			EquatableValue(name: "E", rev: 0), // 1
			EquatableValue(name: "F", rev: 0), // 2
			EquatableValue(name: "G", rev: 0), // 3
		]

		let changeset = source.changeset(to: dest)

		XCTAssertEqual(changeset.updated.count, 0)
		XCTAssertEqual(changeset.deleted.count, 0)
		XCTAssertEqual(changeset.inserted.count, 1)

		// Insert All
		let insertedRange = changeset.inserted.first!
		XCTAssertEqual(insertedRange.lowerBound, 0)
		XCTAssertEqual(insertedRange.upperBound, 4)

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

		let changeset = source.changeset(to: dest)

		XCTAssertEqual(changeset.updated.count, 0)
		XCTAssertEqual(changeset.deleted.count, 1)
		XCTAssertEqual(changeset.inserted.count, 0)

		// Delete All
		let deletedRange = changeset.deleted.first!
		XCTAssertEqual(deletedRange.lowerBound, 0)
		XCTAssertEqual(deletedRange.upperBound, 3)

		// This was a full replacement
		XCTAssertTrue(changeset.wasReplaced)

		// Test tracking of indexes across the changeset.
		XCTAssert(changeset.afterIndexFor(beforeIndex: 0) == nil)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 1) == nil)
		XCTAssert(changeset.afterIndexFor(beforeIndex: 2) == nil)
	}
}
