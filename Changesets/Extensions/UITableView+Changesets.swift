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
	private func applyInsertions(tableView: UITableView, indexPaths: [NSIndexPath]) {
		tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: insertAnimation)
	}

	private func applyDeletions(tableView: UITableView, indexPaths: [NSIndexPath]) {
		tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: deleteAnimation)
	}

	private func applyUpdates(tableView: UITableView, indexPaths: [NSIndexPath]) {
		tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: updateAnimation)
	}
}

// ----------------------------------------------------------------------------
// MARK: - UITableView Extension

extension UITableView {
	/// Applies the `Changeset` to the UITableView by inserting, deleting, or 
	/// reloading the index paths. The default animation policy to to use the
	/// .Automatic row animation for all change kinds.
	///
	/// The changes are processed within `beginUpdates` and `endUpdates` so
	/// they are animated together.
	///
	/// When the entire collection is replaced, it can optionally reload the
	/// data rather than animating inserts and deletes depending on the policy.
	public func applyChangeset(changeset: Changeset, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		if changeset.wasReplaced && policy.reloadForReplacements {
			reloadData()
			return
		}

		beginUpdates()

		policy.applyUpdates(self, indexPaths: changeset.updatedIndexPaths)
		policy.applyDeletions(self, indexPaths: changeset.deletedIndexPaths)
		policy.applyInsertions(self, indexPaths: changeset.insertedIndexPaths)

		endUpdates()
	}

	// TODO: We may want to provide an applyChangeset(changeset: toSection: ...) later...
}
