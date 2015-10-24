//
//  MatchableValue.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-25.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import Changesets

/// MatchableValue uses `name` as the identity, and `rev` as a revision number
/// to change its value.
struct MatchableValue {
	let name: String
	let rev: Int

	init(name: String) {
		self.name = name
		self.rev = 0
	}

	init(name: String, rev: Int) {
		self.name = name
		self.rev = rev
	}
}

extension MatchableValue: Matchable {
	func matchWith(other: MatchableValue) -> MatchResult {
		if name == other.name {
			if rev == other.rev {
				return .SameIdentityEqualValue
			} else {
				return .SameIdentityInequalValue
			}
		} else {
			return .DifferentIdentity
		}
	}
}
