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
	private let insertAnimation: UITableViewRowAnimation
	private let deleteAnimation: UITableViewRowAnimation
	private let updateAnimation: UITableViewRowAnimation

	/// Initializes a new policy with customizable table view row animations for
	/// 'insert', 'delete', and 'update' changes.
	public init(insertAnimation: UITableViewRowAnimation, deleteAnimation: UITableViewRowAnimation, updateAnimation: UITableViewRowAnimation) {
		self.insertAnimation = insertAnimation
		self.deleteAnimation = deleteAnimation
		self.updateAnimation = updateAnimation
	}

	/// The default Changeset Policy is to use the 'Automatic' row animation for
	/// all changes.
	public static var defaultPolicy: TableViewChangesetPolicy {
		return TableViewChangesetPolicy(insertAnimation: .Automatic, deleteAnimation: .Automatic, updateAnimation: .Automatic)
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
	public func applyChangeset(changeset: Changeset, animationPolicy policy: TableViewChangesetPolicy = TableViewChangesetPolicy.defaultPolicy) {
		beginUpdates()

		policy.applyUpdates(self, indexPaths: changeset.updatedIndexPaths)
		policy.applyDeletions(self, indexPaths: changeset.deletedIndexPaths)
		policy.applyInsertions(self, indexPaths: changeset.insertedIndexPaths)

		endUpdates()
	}

	// TODO: We may want to provide an applyChangeset(changeset: toSection: ...) later...
}
