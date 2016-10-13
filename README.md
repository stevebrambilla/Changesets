# Changesets [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Travis CI](https://api.travis-ci.org/stevebrambilla/Changesets.svg?branch=master)](https://travis-ci.org/stevebrambilla/Changesets)

Changesets is a small library used to drive `UITableView` or `UICollectionView` transitions when the underlying model changes.

If your table view or collection view's data source is backed by a `Collection` (eg. `Array`), `Changesets` can calculate the **inserts**, **deletes**, and **updates** to transition between states.

**Example:**

```swift
var people: [Person] {
  didSet {
    // Calculate the changeset.
    let changeset = oldValue.changeset(to: people)

    // Start the transition animation - rows are animated using an .automatic row animation by default.
    tableView.performUpdates(changeset: changeset)
  }
}
```

This is just like the delegate callbacks that a `NSFetchedResultsController`would emit when using Core Data. With `Changesets` you get the fine-grained transitions without having to use Core Data.

For example: to transition an array from its original state:

| A<sub>0</sub> | B<sub>0</sub> | C<sub>0</sub> | D<sub>0</sub> | H<sub>0</sub> | I<sub>0</sub> |
|---------------|---------------|---------------|---------------|---------------|---------------|

to its new state:

| B<sub>0</sub> | C<sub>0</sub> | D<sub>1</sub> | F<sub>0</sub> | H<sub>0</sub> | I<sub>1</sub> | K<sub>0</sub> |
|---------------|---------------|---------------|---------------|---------------|---------------|---------------|

The changeset would report the following changes to perform the transition:

- Update 'D' at index 3
- Update 'I' at index 5
- Delete 'A' at index 0
- Insert 'F' at index 3
- Insert 'G' at index 4
- Insert 'K' at index 7

`Changesets` takes care of all the nitty-gritty details when updating a table view or collection view. It calculates the diff between the old value and the new value, applies the updates in the correct order, and batches them so they are animated together. All of this in two lines of code: 

```swift
let changeset = oldValue.changeset(to: newValue)
collectionView.performUpdates(changeset: changeset))
```

## Usage

To calculate the changeset it needs to _match_ the collections' elements to each other. It supports two methods of matching:

### Matching with `Equatable`

Elements that implement `Equatable` can be matched, with a restriction. When `Equatable` is used, `Changesets` can't tell the difference between an object in the collection that has changed and two completely different objects. All it knows is that the two values aren't equal. The `Equatable` protocol doesn't have any concept of _identity_. 

When an element is only `Equatable`, we cannot know that A<sub>1</sub> is an updated version of A<sub>0</sub>, so `Changesets` will report this by doing a **delete** then **insert**, rather than an **update**:

- Delete A<sub>0</sub>
- Insert A<sub>1</sub>

### Matching with `Matchable`

To use finer-grained changesets you need to take identity into consideration. To do this you can use the `Matchable` protocol. It's recommended that you implement `Matchable` for all your types that are used for data sources. `Matchable` requires one additional function to be implemented for each type:

```swift
func match(_ other: Self) -> MatchResult
```

Where the `MatchResult` is one of three cases:

```swift
public enum MatchResult {
  case sameIdentityEqualValue
  case sameIdentityInequalValue
  case differentIdentity
}
```

`Matchable` also provides a default implementation for `==`, so implementing the `Matchable` protocol gives you `Equatable` for free.

A `User` struct could be implemented as follows:

```swift
struct User: Matchable {
  let userID: Int
  let name: String
  let messageCount: Int

  func match(_ other: User) -> MatchResult {
    guard userID == other.userID else {
      return .differentIdentity
    }

    if name == other.name && messageCount == other.messageCount {
      return .sameIdentityEqualValue
    } else {
      return .sameIdentityInequalValue
    }
  }
}
```

This way, when the `messageCount` value changes, `Changesets` can still recognize that the changed values represent the same user.

### Updating `UITableViews` and `UICollectionViews`

The first step is to calculate the changeset between the old state of the collection and the new state:

```swift
let changeset = oldValue.changeset(to: newValue)
```

If your data is in a single section you can perform the updates to a `UITableView` with a single line:

```swift
tableView.performUpdates(changeset: changeset)
```

Or, a `UICollectionView`:

```swift
collectionView.performUpdates(changeset: changeset)
```

#### Animations

The default row animation when updating a `UITableView` is the `.automatic` row animation. However, the animation can be configured using a custom `TableViewChangesetPolicy`. The `UITableViewRowAnimation` values for inserting, deleting, and updating can all be configured.

The animations for `UICollectionViews` are defined by the collection view layout and are not affected by using changesets.

#### Sectioned Data

If your data is structured in sections you can split the calculations into two steps:

1. Calculate the changeset between the sections.
2. Calculate the changesets between each section's items.

Multiple changesets can be applied by using batch updates. For `UITableView`:

```swift
tableView.beginUpdates()
tableView.applySectionUpdates(changeset: sectionsChangeset) // Insert / delete sections
tableView.applyRowUpdates(changeset: rowChangeset, fromSection: fromSection, toSection: toSection) // One changeset for each section
tableView.endUpdates()
```

And, for `UICollectionView`:

```swift
collectionView.performBatchUpdates({
  collectionView.applySectionUpdates(changeset: sectionsChangeset) // Insert / delete sections
  collectionView.applyItemUpdates(changeset: itemsChangeset, fromSection: fromSection, toSection: toSection) // One changeset for each section
}, completion: nil)
```

## Installation

If you’re using [Carthage](https://github.com/Carthage/Carthage), simply add Changesets to your `Cartfile`:

```
github "stevebrambilla/Changesets"
```

Otherwise, you can manually install it by following these steps:

1. Add the Changesets repository as a submodule of your project's repository.
2. Drag and drop **Changesets.xcodeproj** into your Xcode project or workspace.
3. In the “General” tab of your application target’s settings, add `Changesets.framework` to the “Embedded Binaries” section.

Now `import Changesets` and you're all set.

## Contact

- [Steve Brambilla](http://github.com/stevebrambilla)

## License

Changesets is available under the MIT license. See the LICENSE file for more information.
