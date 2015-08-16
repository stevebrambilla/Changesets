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
/// FastImperfect is the default precision unless overridden.
public enum DiffPrecision {
	case FastImperfect
	case Medium
	case SlowPerfect
}

extension CollectionType where Generator.Element: Equatable, Index == Int {
	/// Calculates the diff between two collections using the equality operator 
	/// for matching.
	///
	/// Returns a `DiffResultsSpan` that represents the changes indexes.
	public func diff(dest: Self, precision: DiffPrecision = .FastImperfect) -> [DiffResultSpan] {
		let engine = DiffEngine(sourceList: self, destList: dest, precision: precision) { $0 == $1 }
		return engine.diffReport()
	}
}

extension CollectionType where Index == Int {
	/// Calculates the diff between two collections using the `isMatch` closure
	/// for matching.
	///
	/// Returns a `DiffResultsSpan` that represents the changes indexes.
	public func diff(dest: Self, precision: DiffPrecision = .FastImperfect, isMatch: (Generator.Element, Generator.Element) -> Bool) -> [DiffResultSpan] {
		let engine = DiffEngine(sourceList: self, destList: dest, precision: precision, isMatch: isMatch)
		return engine.diffReport()
	}
}
