//
//  DiffStatus.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-16.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

internal enum DiffStatus: Equatable {
	case Unknown
	case Matched(start: Int, length: Int)
	case NoMatch

	internal func validate(newStart: Int, newEnd: Int, maxPossibleDestLength: Int) -> DiffStatus {
		switch self {
		case let .Matched(start, length):
			let endIndex = start + length - 1
			if maxPossibleDestLength < length || start < newStart || endIndex > newEnd {
				return .Unknown
			}
			return self

		case .NoMatch:
			return self

		case .Unknown:
			return self
		}
	}
}

internal func == (lhs: DiffStatus, rhs: DiffStatus) -> Bool {
	switch (lhs, rhs) {
	case (.Unknown, .Unknown):
		return true
	case let (.Matched(lStart, lLength), .Matched(rStart, rLength)):
		return lStart == rStart && lLength == rLength
	case (.NoMatch, .NoMatch):
		return true
	default:
		return false
	}
}

extension DiffStatus: CustomStringConvertible {
	internal var description: String {
		switch self {
		case let .Matched(start, length): return "{ Matched: start = \(start), length = \(length) }"
		case .NoMatch: return "{ NoMatch }"
		case .Unknown: return "{ Unknown }"
		}
	}
}
