//
//  DiffTests.swift
//  ChangesetsTests
//
//  Created by Steve Brambilla on 2015-05-16.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import UIKit
import XCTest
@testable import Changesets

class DiffTests: XCTestCase {
    func testDiff() {
		let source = [1, 2, 3, 9, 8, 2, 3, 4, 5, 6]
		let dest = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

		let report = source.diff(dest, precision: .FastImperfect)

		XCTAssertEqual(report.count, 4)

		let span1 = report[0]
		XCTAssertTrue(span1.isNoChange)
		XCTAssertEqual(span1.sourceIndex!, 0)
		XCTAssertEqual(span1.destIndex!, 0)
		XCTAssertEqual(span1.length, 3)

		let span2 = report[1]
		XCTAssertTrue(span2.isDelete)
		XCTAssertEqual(span2.sourceIndex!, 3)
		XCTAssertEqual(span2.length, 4)

		let span3 = report[2]
		XCTAssertTrue(span3.isNoChange)
		XCTAssertEqual(span3.sourceIndex!, 7)
		XCTAssertEqual(span3.destIndex!, 3)
		XCTAssertEqual(span3.length, 3)

		let span4 = report[3]
		XCTAssertTrue(span4.isAdd)
		XCTAssertEqual(span4.destIndex!, 6)
		XCTAssertEqual(span4.length, 4)
    }

	func testInsertMiddle() {
		let source = [1, 3]
		let dest = [1, 2, 3]

		let report = source.diff(dest, precision: .FastImperfect)

		XCTAssertEqual(report.count, 3)

		let span1 = report[0]
		XCTAssertTrue(span1.isNoChange)
		XCTAssertEqual(span1.sourceIndex!, 0)
		XCTAssertEqual(span1.destIndex!, 0)
		XCTAssertEqual(span1.length, 1)

		let span2 = report[1]
		XCTAssertTrue(span2.isAdd)
		XCTAssertEqual(span2.destIndex!, 1)
		XCTAssertEqual(span2.length, 1)

		let span3 = report[2]
		XCTAssertTrue(span3.isNoChange)
		XCTAssertEqual(span3.sourceIndex!, 1)
		XCTAssertEqual(span3.destIndex!, 2)
		XCTAssertEqual(span3.length, 1)
	}

	func testDeleteTail() {
		let source = [1, 2, 3]
		let dest = [1, 2]

		let report = source.diff(dest, precision: .FastImperfect)

		XCTAssertEqual(report.count, 2)

		let span1 = report[0]
		XCTAssertTrue(span1.isNoChange)
		XCTAssertEqual(span1.sourceIndex!, 0)
		XCTAssertEqual(span1.destIndex!, 0)
		XCTAssertEqual(span1.length, 2)

		let span2 = report[1]
		XCTAssertTrue(span2.isDelete)
		XCTAssertEqual(span2.sourceIndex!, 2)
		XCTAssertEqual(span2.length, 1)
	}

	func testReplaceAll() {
		let source = [1, 2, 3]
		let dest = [4, 5, 6, 7]

		let report = source.diff(dest, precision: .FastImperfect)

		XCTAssertEqual(report.count, 2)

		let span1 = report[0]
		XCTAssertTrue(span1.isReplace)
		XCTAssertEqual(span1.sourceIndex!, 0)
		XCTAssertEqual(span1.destIndex!, 0)
		XCTAssertEqual(span1.length, 3)

		let span2 = report[1]
		XCTAssertTrue(span2.isAdd)
		XCTAssertEqual(span2.destIndex!, 3)
		XCTAssertEqual(span2.length, 1)
	}

	func testInsertAndDelete() {
		let source = [1, 5, 6, 7]
		let dest = [1, 3, 5, 7]

		let report = source.diff(dest, precision: .FastImperfect)

		XCTAssertEqual(report.count, 5)

		let span1 = report[0]
		XCTAssertTrue(span1.isNoChange)
		XCTAssertEqual(span1.length, 1)

		let span2 = report[1]
		XCTAssertTrue(span2.isAdd)
		XCTAssertEqual(span2.destIndex!, 1)
		XCTAssertEqual(span2.length, 1)

		let span3 = report[2]
		XCTAssertTrue(span3.isNoChange)
		XCTAssertEqual(span3.length, 1)

		let span4 = report[3]
		XCTAssertTrue(span4.isDelete)
		XCTAssertEqual(span4.sourceIndex!, 2)
		XCTAssertEqual(span4.length, 1)

		let span5 = report[4]
		XCTAssertTrue(span5.isNoChange)
		XCTAssertEqual(span5.length, 1)
	}
}
