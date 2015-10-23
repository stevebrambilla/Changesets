//
//  DiffResultSpan.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-16.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

internal enum DiffResultSpan {
	case NoChange(sourceIndex: Int, destIndex: Int, length: Int)
	case Replace(sourceIndex: Int, destIndex: Int, length: Int)
	case Delete(sourceIndex: Int, length: Int)
	case Add(destIndex: Int, length: Int)

	internal func addLength(length n: Int) -> DiffResultSpan {
		switch self {
		case let .NoChange(sourceIndex, destIndex, length): return .NoChange(sourceIndex: sourceIndex, destIndex: destIndex, length: length + n)
		case let .Replace(sourceIndex, destIndex, length): return .Replace(sourceIndex: sourceIndex, destIndex: destIndex, length: length + n)
		case let .Delete(sourceIndex, length): return .Delete(sourceIndex: sourceIndex, length: length + n)
		case let .Add(destIndex, length): return .Add(destIndex: destIndex, length: length + n)
		}
	}
}

extension DiffResultSpan {
	internal var sourceIndex: Int? {
		switch self {
		case let .NoChange(source, _, _): return source
		case let .Replace(source, _, _): return source
		case let .Delete(source, _): return source
		case .Add: return .None
		}
	}

	internal var destIndex: Int? {
		switch self {
		case let .NoChange(_, dest, _): return dest
		case let .Replace(_, dest, _): return dest
		case .Delete: return .None
		case let .Add(dest, _): return dest
		}
	}

	internal var length: Int {
		switch self {
		case let .NoChange(_, _, len): return len
		case let .Replace(_, _, len): return len
		case let .Delete(_, len): return len
		case let .Add(_, len): return len
		}
	}
}

extension DiffResultSpan {
	internal var isNoChange: Bool {
		switch self {
		case .NoChange: return true
		default: return false
		}
	}

	internal var isReplace: Bool {
		switch self {
		case .Replace: return true
		default: return false
		}
	}

	internal var isDelete: Bool {
		switch self {
		case .Delete: return true
		default: return false
		}
	}

	internal var isAdd: Bool {
		switch self {
		case .Add: return true
		default: return false
		}
	}
}

extension DiffResultSpan: CustomStringConvertible {
	internal var description: String {
		switch self {
		case let .NoChange(sourceIndex, destIndex, length): return "{ NoChange: dest = \(destIndex), source: \(sourceIndex), length: \(length) }"
		case let .Replace(sourceIndex, destIndex, length): return "{ Replace: dest = \(destIndex), source: \(sourceIndex), length: \(length) }"
		case let .Delete(sourceIndex, length): return "{ Delete: source: \(sourceIndex), length: \(length) }"
		case let .Add(destIndex, length): return "{ Add: dest = \(destIndex), length: \(length) }"
		}
	}
}

internal func isOrderedBeforeByDestIndex(lhs: DiffResultSpan, rhs: DiffResultSpan) -> Bool {
	if let lIndex = lhs.destIndex, rIndex = rhs.destIndex {
		return lIndex < rIndex
	} else {
		return false
	}
}
