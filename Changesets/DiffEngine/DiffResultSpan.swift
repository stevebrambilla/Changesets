//
//  DiffResultSpan.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-16.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

internal enum DiffResultSpan {
	case noChange(sourceIndex: Int, destIndex: Int, length: Int)
	case replace(sourceIndex: Int, destIndex: Int, length: Int)
	case delete(sourceIndex: Int, length: Int)
	case add(destIndex: Int, length: Int)

	internal func addLength(length n: Int) -> DiffResultSpan {
		switch self {
		case let .noChange(sourceIndex, destIndex, length): return .noChange(sourceIndex: sourceIndex, destIndex: destIndex, length: length + n)
		case let .replace(sourceIndex, destIndex, length): return .replace(sourceIndex: sourceIndex, destIndex: destIndex, length: length + n)
		case let .delete(sourceIndex, length): return .delete(sourceIndex: sourceIndex, length: length + n)
		case let .add(destIndex, length): return .add(destIndex: destIndex, length: length + n)
		}
	}
}

extension DiffResultSpan {
	internal var sourceIndex: Int? {
		switch self {
		case let .noChange(source, _, _): return source
		case let .replace(source, _, _): return source
		case let .delete(source, _): return source
		case .add: return .none
		}
	}

	internal var destIndex: Int? {
		switch self {
		case let .noChange(_, dest, _): return dest
		case let .replace(_, dest, _): return dest
		case .delete: return .none
		case let .add(dest, _): return dest
		}
	}

	internal var length: Int {
		switch self {
		case let .noChange(_, _, len): return len
		case let .replace(_, _, len): return len
		case let .delete(_, len): return len
		case let .add(_, len): return len
		}
	}
}

extension DiffResultSpan {
	internal var isNoChange: Bool {
		switch self {
		case .noChange: return true
		default: return false
		}
	}

	internal var isReplace: Bool {
		switch self {
		case .replace: return true
		default: return false
		}
	}

	internal var isDelete: Bool {
		switch self {
		case .delete: return true
		default: return false
		}
	}

	internal var isAdd: Bool {
		switch self {
		case .add: return true
		default: return false
		}
	}
}

extension DiffResultSpan: CustomStringConvertible {
	internal var description: String {
		switch self {
		case let .noChange(sourceIndex, destIndex, length): return "{ NoChange: dest = \(destIndex), source: \(sourceIndex), length: \(length) }"
		case let .replace(sourceIndex, destIndex, length): return "{ Replace: dest = \(destIndex), source: \(sourceIndex), length: \(length) }"
		case let .delete(sourceIndex, length): return "{ Delete: source: \(sourceIndex), length: \(length) }"
		case let .add(destIndex, length): return "{ Add: dest = \(destIndex), length: \(length) }"
		}
	}
}

internal func isOrderedBeforeByDestIndex(_ lhs: DiffResultSpan, rhs: DiffResultSpan) -> Bool {
	if let lIndex = lhs.destIndex, let rIndex = rhs.destIndex {
		return lIndex < rIndex
	} else {
		return false
	}
}
