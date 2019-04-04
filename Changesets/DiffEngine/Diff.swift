//
//  Diff.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-18.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

/// The precision of the diff algorithm. The speed differences are significant
/// as the data set size increases.
///
/// .fastImperfect is the default precision unless overridden.
internal enum DiffPrecision {
	case fastImperfect
	case medium
	case slowPerfect
}

extension Collection where Iterator.Element: Equatable, Index == Int {
	/// Calculates the diff between two collections using the equality operator 
	/// for matching.
	///
	/// Returns a `DiffResultsSpan` that represents the changes indexes.
	internal func diff(against source: Self, precision: DiffPrecision = .fastImperfect) -> [DiffResultSpan] {
		let engine = DiffEngine(sourceList: source, destList: self, precision: precision) { $0 == $1 }
		return engine.diffReport()
	}
}

extension Collection where Index == Int {
	/// Calculates the diff between two collections using the `isMatch` closure
	/// for matching.
	///
	/// Returns a `DiffResultsSpan` that represents the changes indexes.
	internal func diff(against source: Self, precision: DiffPrecision = .fastImperfect, isMatch: @escaping (Iterator.Element, Iterator.Element) -> Bool) -> [DiffResultSpan] {
		let engine = DiffEngine(sourceList: source, destList: self, precision: precision, isMatch: isMatch)
		return engine.diffReport()
	}
}
