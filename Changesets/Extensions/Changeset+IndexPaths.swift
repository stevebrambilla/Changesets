//
//  Changeset+IndexPaths.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-08-15.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import Foundation

extension Changeset {
	// Returns the corresponding list of index paths for updated items, assuming
	// the section is zero.
	internal var updatedIndexPaths: [NSIndexPath] {
		return toIndexPaths(updated)
	}

	// Returns the corresponding list of index paths for inserted items,
	// assuming the section is zero.
	internal var insertedIndexPaths: [NSIndexPath] {
		return toIndexPaths(inserted)
	}

	// Returns the corresponding list of index paths for deleted items, assuming
	// the section is zero.
	internal var deletedIndexPaths: [NSIndexPath] {
		return toIndexPaths(deleted)
	}
}

private func toIndexPaths(ranges: [Range<Int>]) -> [NSIndexPath] {
	return ranges.flatMap { range in
		range.map { NSIndexPath(forItem: $0, inSection: 0) }
	}
}
