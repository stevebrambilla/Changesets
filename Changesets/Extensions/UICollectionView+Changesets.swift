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
	///
	/// When the entire collection is replaced, it can optionally reload the
	/// data rather than animating deletes and inserts depending on the value of
	/// `reloadForReplacements`.
	public func applyChangeset(changeset: Changeset, reloadForReplacements: Bool = true, completion: (Bool -> Void)? = nil) {
		if changeset.wasReplaced && reloadForReplacements {
			reloadData()
			return
		}

		performBatchUpdates({
			self.reloadItemsAtIndexPaths(changeset.updatedIndexPaths)
			self.deleteItemsAtIndexPaths(changeset.deletedIndexPaths)
			self.insertItemsAtIndexPaths(changeset.insertedIndexPaths)
		}, completion: completion)
	}

	// TODO: We may want to provide an applyChangeset(changeset: toSection: ...) later...
}
