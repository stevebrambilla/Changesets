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
	internal func updatedIndexPaths(section: Int) -> [IndexPath] {
		return updatedIndexSet.map {
			IndexPath(indexes: [section, $0])
		}
	}

	/// Returns an array of index paths with all of the Changeset's inserted
	/// indexes, using the given `section` as the root index.
	internal func insertedIndexPaths(section: Int) -> [IndexPath] {
		return insertedIndexSet.map {
			IndexPath(indexes: [section, $0])
		}
	}

	/// Returns an array of index paths with all of the Changeset's deleted
	/// indexes, using the given `section` as the root index.
	internal func deletedIndexPaths(section: Int) -> [IndexPath] {
		return deletedIndexSet.map {
			IndexPath(indexes: [section, $0])
		}
	}
}
