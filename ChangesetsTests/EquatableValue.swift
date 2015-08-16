//
//  EquatableValue.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-08-15.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import Foundation
import Changesets

struct EquatableValue: Equatable {
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

func == (lhs: EquatableValue, rhs: EquatableValue) -> Bool {
	return lhs.name == rhs.name && lhs.rev == rhs.rev
}
