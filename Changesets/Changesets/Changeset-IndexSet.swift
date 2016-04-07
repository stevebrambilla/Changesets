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
	public var updatedIndexSet: NSIndexSet {
		let indexSet = NSMutableIndexSet()
		for range in updated {
			indexSet.addIndexesInRange(NSMakeRange(range.startIndex, range.count))
		}
		return indexSet
	}

	/// Returns an index set with all of the changeset's deleted indexes.
	public var deletedIndexSet: NSIndexSet {
		let indexSet = NSMutableIndexSet()
		for range in deleted {
			indexSet.addIndexesInRange(NSMakeRange(range.startIndex, range.count))
		}
		return indexSet
	}

	/// Returns an index set with all of the changeset's inserted indexes.
	public var insertedIndexSet: NSIndexSet {
		let indexSet = NSMutableIndexSet()
		for range in inserted {
			indexSet.addIndexesInRange(NSMakeRange(range.startIndex, range.count))
		}
		return indexSet
	}
}
