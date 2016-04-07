//
//  Changeset-IndexPath.swift
//  Changesets
//
//  Created by Steve Brambilla on 2016-04-06.
//  Copyright © 2016 Steve Brambilla. All rights reserved.
//

import Foundation

extension Changeset {
	/// Returns an array of index paths with all of the Changeset's updated
	/// indexes, using the given `section` as the root index.
	internal func updatedIndexPaths(section: Int) -> [NSIndexPath] {
		return updatedIndexSet.map {
			let indexes = [section, $0]
			return NSIndexPath(indexes: indexes, length: indexes.count)
		}
	}

	/// Returns an array of index paths with all of the Changeset's inserted
	/// indexes, using the given `section` as the root index.
	internal func insertedIndexPaths(section: Int) -> [NSIndexPath] {
		return insertedIndexSet.map {
			let indexes = [section, $0]
			return NSIndexPath(indexes: indexes, length: indexes.count)
		}
	}

	/// Returns an array of index paths with all of the Changeset's deleted
	/// indexes, using the given `section` as the root index.
	internal func deletedIndexPaths(section: Int) -> [NSIndexPath] {
		return deletedIndexSet.map {
			let indexes = [section, $0]
			return NSIndexPath(indexes: indexes, length: indexes.count)
		}
	}
}
