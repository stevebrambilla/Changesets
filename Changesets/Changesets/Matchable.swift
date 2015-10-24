//
//  Matchable.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-24.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation

// ----------------------------------------------------------------------------
// MARK: - Matchable

/// Instances of conforming types can be matched against one another to compare
/// identity and equality.
///
/// By considering identity when comparing objects, Changesets can accuratly
/// differentiate between elements that have been updated (same identities,
/// inequal values) and elements that have otherwise been inserted / deleted
/// (different identities).
public protocol Matchable: Equatable {
	func match(other: Self) -> MatchResult
}

// Any types that implement Matchable's `matchWith()` method get Equatable for
// free.
public func == <T: Matchable>(lhs: T, rhs: T) -> Bool {
	return lhs.match(rhs) == .SameIdentityEqualValue
}

// ----------------------------------------------------------------------------
// MARK: - MatchResult

/// The result of matching two values.
public enum MatchResult {
	/// The matched instances have the same identity and same value. This same
	/// comparison would result in true if compared for value equality.
	case SameIdentityEqualValue

	/// The matched instances have the same identity, but different content.
	/// This same comparison would result in false if compared for value 
	/// equality.
	///
	/// This would be the case if a more recent value was compared against an
	/// older value, yet the two values represent the same identity.
	case SameIdentityInequalValue

	/// The matched instances do not have the same identity or value. This same
	/// comparison would result in false if compared for value equality.
	case DifferentIdentity
}

extension MatchResult {
	/// Returns a MatchResult given two equatable values that are known to have
	/// the same identity.
	public static func sameIdentityCompare<T: Equatable>(lhs: T, _ rhs: T) -> MatchResult {
		return lhs == rhs ? .SameIdentityEqualValue : .SameIdentityInequalValue
	}

	/// Returns a MatchResult given two equatable values that do not have an
	/// identity to compare.
	///
	/// This is low-fidelity matching that is useful for comparing simple types
	/// that don't necessarily have an identity (like Swift's types).
	public static func noIdentityCompare<T: Equatable>(lhs: T, _ rhs: T) -> MatchResult {
		return lhs == rhs ? .SameIdentityEqualValue : .DifferentIdentity
	}
}

/// If `result` is not `EqualIdentityEqualValue`, return it, otherwise evaluate
/// `rhs` as a value equation and return `EqualIdentityEqualValue` or
/// `EqualIdentityInequalValue` depending on the result.
public func && (result: MatchResult, @autoclosure rhs: () -> Bool) -> MatchResult {
	if result == .SameIdentityEqualValue {
		return rhs() ? .SameIdentityEqualValue : .SameIdentityInequalValue
	}
	return result
}

// ----------------------------------------------------------------------------
// MARK: - Swift Types

extension String: Matchable {
	public func match(other: String) -> MatchResult {
		return MatchResult.noIdentityCompare(self, other)
	}
}

extension Int: Matchable {
	public func match(other: Int) -> MatchResult {
		return MatchResult.noIdentityCompare(self, other)
	}
}

extension Double: Matchable {
	public func match(other: Double) -> MatchResult {
		return MatchResult.noIdentityCompare(self, other)
	}
}

extension Float: Matchable {
	public func match(other: Float) -> MatchResult {
		return MatchResult.noIdentityCompare(self, other)
	}
}

extension Bool: Matchable {
	public func match(other: Bool) -> MatchResult {
		return MatchResult.noIdentityCompare(self, other)
	}
}
