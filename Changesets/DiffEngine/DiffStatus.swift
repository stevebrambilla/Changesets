//
//  DiffStatus.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-16.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

internal enum DiffStatus: Equatable {
	case unknown
	case matched(start: Int, length: Int)
	case noMatch

	internal func validate(newStart: Int, newEnd: Int, maxPossibleDestLength: Int) -> DiffStatus {
		switch self {
		case let .matched(start, length):
			let endIndex = start + length - 1
			if maxPossibleDestLength < length || start < newStart || endIndex > newEnd {
				return .unknown
			}
			return self

		case .noMatch:
			return self

		case .unknown:
			return self
		}
	}
}

internal func == (lhs: DiffStatus, rhs: DiffStatus) -> Bool {
	switch (lhs, rhs) {
	case (.unknown, .unknown):
		return true
	case let (.matched(lStart, lLength), .matched(rStart, rLength)):
		return lStart == rStart && lLength == rLength
	case (.noMatch, .noMatch):
		return true
	default:
		return false
	}
}

extension DiffStatus: CustomStringConvertible {
	internal var description: String {
		switch self {
		case let .matched(start, length): return "{ Matched: start = \(start), length = \(length) }"
		case .noMatch: return "{ NoMatch }"
		case .unknown: return "{ Unknown }"
		}
	}
}
