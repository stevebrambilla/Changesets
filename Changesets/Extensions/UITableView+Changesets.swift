//
//  UITableView+Changesets.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-06-13.
//  Copyright © 2015 Steve Brambilla. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------------------
// MARK: - ChangeSet Animation Policy

/// A policy that determines how inserted, deleted, and updated rows are 
/// animated when a `Changeset` is applied to a `UITableView`.
///
/// A custom row animation can be specified for each change kind.
public struct TableViewChangesetPolicy {
	public let insertAnimation: UITableView.RowAnimation
	public let deleteAnimation: UITableView.RowAnimation
	public let updateAnimation: UITableView.RowAnimation
	public let reloadForReplacements: Bool

	/// Initializes a new policy with customizable table view row animations for
	/// 'insert', 'delete', and 'update' changes.
	public init(insertAnimation: UITableView.RowAnimation, deleteAnimation: UITableView.RowAnimation, updateAnimation: UITableView.RowAnimation, reloadForReplacements: Bool) {
		self.insertAnimation = insertAnimation
		self.deleteAnimation = deleteAnimation
		self.updateAnimation = updateAnimation
		self.reloadForReplacements = reloadForReplacements
	}

	/// The default Changeset Policy is to use the 'Automatic' row animation for
	/// all changes.
	public static var defaultPolicy: TableViewChangesetPolicy {
		return TableViewChangesetPolicy(insertAnimation: .automatic, deleteAnimation: .automatic, updateAnimation: .automatic, reloadForReplacements: false)
	}
}

extension TableViewChangesetPolicy {
	fileprivate func applySectionInsertions(tableView: UITableView, sections: IndexSet) {
		tableView.insertSections(sections, with: insertAnimation)
	}

	fileprivate func applySectionDeletions(tableView: UITableView, sections: IndexSet) {
		tableView.deleteSections(sections, with: deleteAnimation)
	}

	fileprivate func applySectionUpdates(tableView: UITableView, sections: IndexSet) {
		tableView.reloadSections(sections, with: updateAnimation)
	}

	fileprivate func applyRowInsertions(tableView: UITableView, indexPaths: [IndexPath]) {
		tableView.insertRows(at: indexPaths, with: insertAnimation)
	}

	fileprivate func applyRowDeletions(tableView: UITableView, indexPaths: [IndexPath]) {
		tableView.deleteRows(at: indexPaths, with: deleteAnimation)
	}

	fileprivate func applyRowUpdates(tableView: UITableView, indexPaths: [IndexPath]) {
		tableView.reloadRows(at: indexPaths, with: updateAnimation)
	}
}

// ----------------------------------------------------------------------------
// MARK: - UITableView Extension

extension UITableView {
	/// Applies the `Changeset` to the UITableView by inserting, deleting, or 
	/// reloading the rows in the first section. This assumes the table view is
	/// displaying a single section.
	///
	/// The changes are processed within `beginUpdates` and `endUpdates` so
	/// they are animated together.
	///
	/// The default animation policy to to use the .Automatic row animation for
	/// all change kinds. When the entire collection is replaced, it can
	/// optionally reload the data rather than animating inserts and deletes 
	/// depending on the policy.
	public func performUpdates(changeset: Changeset, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		if changeset.wasReplaced && policy.reloadForReplacements {
			reloadData()
			return
		}

		beginUpdates()

		policy.applyRowUpdates(tableView: self, indexPaths: changeset.updatedIndexPaths(section: 0))
		policy.applyRowDeletions(tableView: self, indexPaths: changeset.deletedIndexPaths(section: 0))
		policy.applyRowInsertions(tableView: self, indexPaths: changeset.insertedIndexPaths(section: 0))

		endUpdates()
	}

	/// Calls the section updating methods corresponding to the changeset, in
	/// the following order:
	///
	/// - reloadSections(_: with:)
	/// - deleteSections(_: with:)
	/// - insertSections(_: with:)
	///
	/// This method does not perform any batching. Batching is left to the
	/// caller so that calls to updateSections(changeset:) and
	/// updateRows(changeset:) can be combined within the same batch.
	///
	/// - parameter changeset: the set of section changes to pass through to the
	///   table view.
	/// - parameter policy: optionally override the default animation policy.
	public func applySectionUpdates(changeset: Changeset, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		policy.applySectionUpdates(tableView: self, sections: changeset.updatedIndexSet)
		policy.applySectionDeletions(tableView: self, sections: changeset.deletedIndexSet)
		policy.applySectionInsertions(tableView: self, sections: changeset.insertedIndexSet)
	}

	/// Calls the item updating methods corresponding to the changeset, in
	/// the following order:
	///
	/// - reloadRows(at: with:)
	/// - deleteRows(at: with:)
	/// - insertRows(at: with:)
	///
	/// This method does not perform any batching. Batching is left to the
	/// caller so that calls to updateSections(changeset:) and
	/// updateRows(changeset:) can be combined within the same batch.
	///
	/// The "from" and "to" sections must be specified so the correct index
	/// paths can be constructed from the Changeset.
	///
	/// - parameter changeset: the set of row changes to pass through to the
	///   table view.
	/// - parameter fromSection: the section index relative to the table view’s 
	///   state _before_ the changeset.
	/// - parameter toSection: the section index relative to the table view's
	///   state _after_ the changeset.
	public func applyRowUpdates(changeset: Changeset, fromSection: Int, toSection: Int, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		policy.applyRowUpdates(tableView: self, indexPaths: changeset.updatedIndexPaths(section: fromSection))
		policy.applyRowDeletions(tableView: self, indexPaths: changeset.deletedIndexPaths(section: fromSection))
		policy.applyRowInsertions(tableView: self, indexPaths: changeset.insertedIndexPaths(section: toSection))
	}
}
