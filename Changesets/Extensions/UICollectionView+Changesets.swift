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
	/// or reloading the items in the first section. This assumes the collection
	/// view is displaying a single section.
	///
	/// The changes are performed as a batch update so they are animated 
	/// together.
	///
	/// When the entire collection is replaced, it can optionally reload the
	/// data rather than animating deletes and inserts depending on the value of
	/// `reloadForReplacements`.
	public func performUpdates(changeset: Changeset, reloadForReplacements: Bool = true, completion: ((Bool) -> Void)? = nil) {
		if changeset.wasReplaced && reloadForReplacements {
			reloadData()
			return
		}

		performBatchUpdates({
			self.reloadItems(at: changeset.updatedIndexPaths(section: 0))
			self.deleteItems(at: changeset.deletedIndexPaths(section: 0))
			self.insertItems(at: changeset.insertedIndexPaths(section: 0))
		}, completion: completion)
	}

	/// Calls the section updating methods corresponding to the changeset, in
	/// the following order:
	///
	/// - reloadSections(sections:)
	/// - deleteSections(sections:)
	/// - insertSections(sections:)
	///
	/// This method does not perform any batching. Batching is left to the 
	/// caller so that calls to updateSections(changeset:) and
	/// updateItems(changeset:) can be combined within the same batch.
	///
	/// - parameter changeset: the set of section changes to pass through to the
	///   collection view.
	public func applySectionUpdates(changeset: Changeset) {
		reloadSections(changeset.updatedIndexSet)
		deleteSections(changeset.deletedIndexSet)
		insertSections(changeset.insertedIndexSet)
	}

	/// Calls the item updating methods corresponding to the changeset, in
	/// the following order:
	///
	/// - reloadItems(at:)
	/// - deleteItems(at:)
	/// - insertItems(at:)
	///
	/// This method does not perform any batching. Batching is left to the
	/// caller so that calls to updateSections(changeset:) and
	/// updateItems(changeset:) can be combined within the same batch.
	///
	/// The "from" and "to" sections must be specified so the correct index 
	/// paths can be constructed from the Changeset.
	///
	/// - parameter changeset: the set of item changes to pass through to the
	///   collection view.
	/// - parameter fromSection: the section index relative to the collection 
	///   view’s state _before_ the changeset.
	/// - parameter toSection: the section index relative to the collection
	///   view’s state _after_ the changeset.
	public func applyItemUpdates(changeset: Changeset, fromSection: Int, toSection: Int) {
		reloadItems(at: changeset.updatedIndexPaths(section: fromSection))
		deleteItems(at: changeset.deletedIndexPaths(section: fromSection))
		insertItems(at: changeset.insertedIndexPaths(section: toSection))
	}
}
