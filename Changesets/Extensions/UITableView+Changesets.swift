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
	public let insertAnimation: UITableViewRowAnimation
	public let deleteAnimation: UITableViewRowAnimation
	public let updateAnimation: UITableViewRowAnimation
	public let reloadForReplacements: Bool

	/// Initializes a new policy with customizable table view row animations for
	/// 'insert', 'delete', and 'update' changes.
	public init(insertAnimation: UITableViewRowAnimation, deleteAnimation: UITableViewRowAnimation, updateAnimation: UITableViewRowAnimation, reloadForReplacements: Bool) {
		self.insertAnimation = insertAnimation
		self.deleteAnimation = deleteAnimation
		self.updateAnimation = updateAnimation
		self.reloadForReplacements = reloadForReplacements
	}

	/// The default Changeset Policy is to use the 'Automatic' row animation for
	/// all changes.
	public static var defaultPolicy: TableViewChangesetPolicy {
		return TableViewChangesetPolicy(insertAnimation: .Automatic, deleteAnimation: .Automatic, updateAnimation: .Automatic, reloadForReplacements: false)
	}
}

extension TableViewChangesetPolicy {
	private func applySectionInsertions(tableView: UITableView, sections: NSIndexSet) {
		tableView.insertSections(sections, withRowAnimation: insertAnimation)
	}

	private func applySectionDeletions(tableView: UITableView, sections: NSIndexSet) {
		tableView.deleteSections(sections, withRowAnimation: deleteAnimation)
	}

	private func applySectionUpdates(tableView: UITableView, sections: NSIndexSet) {
		tableView.reloadSections(sections, withRowAnimation: updateAnimation)
	}

	private func applyRowInsertions(tableView: UITableView, indexPaths: [NSIndexPath]) {
		tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: insertAnimation)
	}

	private func applyRowDeletions(tableView: UITableView, indexPaths: [NSIndexPath]) {
		tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: deleteAnimation)
	}

	private func applyRowUpdates(tableView: UITableView, indexPaths: [NSIndexPath]) {
		tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: updateAnimation)
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
	public func applyChangeset(changeset: Changeset, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		if changeset.wasReplaced && policy.reloadForReplacements {
			reloadData()
			return
		}

		beginUpdates()

		policy.applyRowUpdates(self, indexPaths: changeset.updatedIndexPaths(0))
		policy.applyRowDeletions(self, indexPaths: changeset.deletedIndexPaths(0))
		policy.applyRowInsertions(self, indexPaths: changeset.insertedIndexPaths(0))

		endUpdates()
	}

	///
	/// NOTE: Does not trigger reload
	/// NOTE: Must be called withing update blocks


	/// Calls the section updating methods corresponding to the changeset, in
	/// the following order:
	///
	/// - reloadSections(sections:withRowAnimation:)
	/// - deleteSections(sections:withRowAnimation:)
	/// - insertSections(sections:withRowAnimation:)
	///
	/// This method does not perform any batching. Batching is left to the
	/// caller so that calls to updateSections(changeset:) and
	/// updateRows(changeset:) can be combined within the same batch.
	///
	/// - parameter changeset: the set of section changes to pass through to the
	///   table view.
	/// - parameter policy: optionally override the default animation policy.
	public func updateSections(changeset: Changeset, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		policy.applySectionUpdates(self, sections: changeset.updatedIndexSet)
		policy.applySectionDeletions(self, sections: changeset.deletedIndexSet)
		policy.applySectionInsertions(self, sections: changeset.insertedIndexSet)
	}

	/// Calls the item updating methods corresponding to the changeset, in
	/// the following order:
	///
	/// - reloadRowsAtIndexPaths(indexPaths:)
	/// - deleteRowsAtIndexPaths(indexPaths:)
	/// - insertRowsAtIndexPaths(indexPaths:)
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
	public func updateRows(changeset: Changeset, fromSection: Int, toSection: Int, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		policy.applyRowUpdates(self, indexPaths: changeset.updatedIndexPaths(fromSection))
		policy.applyRowDeletions(self, indexPaths: changeset.deletedIndexPaths(fromSection))
		policy.applyRowInsertions(self, indexPaths: changeset.insertedIndexPaths(toSection))
	}
}
