//
//  UICollectionView+Changesets.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-08-15.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - UICollectionView Extension

extension UICollectionView {
	/// Applies the `Changeset` to the UICollectionView by inserting, deleting,
	/// or reloading the index paths.
	///
	/// The changes are performed as a batch update so they are animated 
	/// together.
	public func applyChangeset(changeset: Changeset, completion: (Bool -> Void)? = nil) {
		performBatchUpdates({
			self.reloadItemsAtIndexPaths(changeset.updatedIndexPaths)
			self.deleteItemsAtIndexPaths(changeset.deletedIndexPaths)
			self.insertItemsAtIndexPaths(changeset.insertedIndexPaths)
		}, completion: completion)
	}

	// TODO: We may want to provide an applyChangeset(changeset: toSection: ...) later...
}
