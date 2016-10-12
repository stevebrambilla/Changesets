//
//  Changeset-IndexSets.swift
//  Changesets
//
//  Created by Steve Brambilla on 2016-04-06.
//  Copyright © 2016 Steve Brambilla. All rights reserved.
//

import Foundation

extension Changeset {
	/// Returns an index set with all of the changeset's updated indexes.
	public var updatedIndexSet: IndexSet {
		var indexSet = IndexSet()
		for range in updated {
			indexSet.insert(integersIn: range)
		}
		return indexSet
	}

	/// Returns an index set with all of the changeset's deleted indexes.
	public var deletedIndexSet: IndexSet {
		var indexSet = IndexSet()
		for range in deleted {
			indexSet.insert(integersIn: range)
		}
		return indexSet
	}

	/// Returns an index set with all of the changeset's inserted indexes.
	public var insertedIndexSet: IndexSet {
		var indexSet = IndexSet()
		for range in inserted {
			indexSet.insert(integersIn: range)
		}
		return indexSet
	}
}
