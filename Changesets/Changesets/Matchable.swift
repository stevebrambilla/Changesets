//
//  Matchable.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-24.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

/// The result of matching two values.
public enum MatchResult {
	/// The matched instances have the same identity and same value. This same
	/// comparison would result in true if compared for value equality.
	case EqualIdentityEqualValue

	/// The matched instances have the same identity, but different content.
	/// This same comparison would result in false if compared for value 
	/// equality.
	///
	/// This would be the case if a newer instance was compared against an
	/// older instance, but they represent the same identity.
	case EqualIdentityInequalValue

	/// The matched instances do not have the same identity or value. This same
	/// comparison would result in false if compared for value equality.
	case InequalIdentity
}

/// Instances of conforming types can be matched against one another to compare
/// identity and equality.
///
/// By considering identity when comparing objects, Changesets can accuratly 
/// differentiate between elements that have been updated (same identities,
/// inequal values) and elements that have otherwise been inserted / deleted 
/// (different identities).
public protocol Matchable: Equatable {
	func matchWith(other: Self) -> MatchResult
}

// Any types that implement Matchable's `matchWith()` method get Equatable for
// free.
public func == <T: Matchable>(lhs: T, rhs: T) -> Bool {
	return lhs.matchWith(rhs) == .EqualIdentityEqualValue
}

/// If `result` is not `EqualIdentityEqualValue`, return it, otherwise evaluate
/// `rhs` as a value equation and return `EqualIdentityEqualValue` or
/// `EqualIdentityInequalValue` depending on the result.
public func && (result: MatchResult, @autoclosure rhs: () -> Bool) -> MatchResult {
	if result == .EqualIdentityEqualValue {
		return rhs() ? .EqualIdentityEqualValue : .EqualIdentityInequalValue
	}
	return result
}

/// Low-fidelity matching for `Equatable`s.
///
/// Comparing values this way does not consider identity when matching.
internal func matchWithoutIdentity<T: Equatable>(lhs: T, _ rhs: T) -> MatchResult {
	return lhs == rhs ? .EqualIdentityEqualValue : .InequalIdentity
}

// ----------------------------------------------------------------------------
// MARK: - Swift Types

extension String: Matchable {
	public func matchWith(other: String) -> MatchResult {
		return matchWithoutIdentity(self, other)
	}
}

extension Int: Matchable {
	public func matchWith(other: Int) -> MatchResult {
		return matchWithoutIdentity(self, other)
	}
}

extension Double: Matchable {
	public func matchWith(other: Double) -> MatchResult {
		return matchWithoutIdentity(self, other)
	}
}

extension Float: Matchable {
	public func matchWith(other: Float) -> MatchResult {
		return matchWithoutIdentity(self, other)
	}
}

extension Bool: Matchable {
	public func matchWith(other: Bool) -> MatchResult {
		return matchWithoutIdentity(self, other)
	}
}
