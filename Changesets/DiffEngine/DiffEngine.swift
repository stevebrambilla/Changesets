//
//  DiffEngine.swift
//  Changesets
//
//  Created by Steve Brambilla on 2015-05-16.
//  Copyright (c) 2015 Steve Brambilla. All rights reserved.
//

// Diff algorithm ported from: http://www.codeproject.com/Articles/6943/A-Generic-Reusable-Diff-Algorithm-in-C-II

import Foundation

internal final class DiffEngine<C: CollectionType, T where C.Index == Int, C.Generator.Element == T> {
	private let sourceList: C
	private let destList: C
	private let isMatch: (T, T) -> Bool

	private let precision: DiffPrecision
	private var matchList = [DiffResultSpan]()
	private var statusTable = [Int: DiffStatus]()

	internal init(sourceList: C, destList: C, precision: DiffPrecision = .FastImperfect, isMatch: (T, T) -> Bool) {
		self.sourceList = sourceList
		self.destList = destList
		self.isMatch = isMatch
		self.precision = precision

		let scount = sourceList.endIndex
		let dcount = destList.endIndex

		if dcount > 0 && scount > 0 {
			statusTable = [Int: DiffStatus](minimumCapacity: max(9, dcount / 10))
			processRange(0, destEnd: dcount - 1, sourceStart: 0, sourceEnd: scount - 1)
		}
	}
}

// ----------------------------------------------------------------------------
// MARK: Matching Algorithm

extension DiffEngine {
	private func findLongestSourceMatch(destIndex: Int, destEnd: Int, sourceStart: Int, sourceEnd: Int) -> DiffStatus {
		let maxDestLength = destEnd - destIndex + 1
		var curBestLength = 0
		var curBestIndex = -1

		for var sourceIndex = sourceStart; sourceIndex <= sourceEnd; sourceIndex++ {
			let maxLength = min(maxDestLength, (sourceEnd - sourceIndex + 1))
			if maxLength <= curBestLength {
				// No chance to find a longer one
				break
			}

			let curLength = findSourceMatchLength(destIndex, sourceIndex: sourceIndex, maxLength: maxLength)
			if curLength > curBestLength {
				// This is the best match so far
				curBestIndex = sourceIndex
				curBestLength = curLength
			}

			// Jump over the match
			sourceIndex += curBestLength
		}

		if curBestIndex == -1 {
			return .NoMatch
		} else {
			return .Matched(start: curBestIndex, length: curBestLength)
		}
	}

	private func findSourceMatchLength(destIndex: Int, sourceIndex: Int, maxLength: Int) -> Int {
		var matchCount: Int
		for matchCount = 0; matchCount < maxLength; matchCount++ {
			if !isMatch(destList[destIndex + matchCount], sourceList[sourceIndex + matchCount]) {
				break
			}
		}
		return matchCount
	}

	private func processRange(destStart: Int, destEnd: Int, sourceStart: Int, sourceEnd: Int) {
		var curBestIndex = -1
		var curBestLength = -1
		var bestItem = DiffStatus.Unknown

		for var destIndex = destStart; destIndex <= destEnd; destIndex++ {
			let maxPossibleDestLength = destEnd - destIndex + 1
			if maxPossibleDestLength <= curBestLength {
				// We won't find a longer one even if we looked
				break;
			}

			var curItem = statusTable[destIndex] ?? .Unknown

			// Revalidate the current item's range
			curItem = curItem.validate(sourceStart, newEnd: sourceEnd, maxPossibleDestLength: maxPossibleDestLength)

			if curItem == .Unknown {
				// Recalc new best length since it isn't valid or has never been done
				curItem = findLongestSourceMatch(destIndex, destEnd: destEnd, sourceStart: sourceStart, sourceEnd: sourceEnd)
			}

			// Add the updated item back to the table
			statusTable[destIndex] = curItem

			switch curItem {
			case let .Matched(_, length):
				if length > curBestLength {
					// This is longest match so far
					curBestIndex = destIndex
					curBestLength = length
					bestItem = curItem
				}

				// Jump ahead depending on the desired precision.
				switch precision {
				case .FastImperfect: // Always jump over the match
					destIndex += length - 1

				case .Medium: // Only jump if a new best match was set
					if curItem == bestItem {
						destIndex += length - 1
					}

				case .SlowPerfect: // Never jump -- evaluate all indexes
					break
				}

			case .NoMatch, .Unknown:
				break
			}
		}

		switch bestItem {
		case let .Matched(sourceIndex, length):
			// Add the best match to the matchList
			matchList.append(.NoChange(sourceIndex: sourceIndex, destIndex: curBestIndex, length: length))

			if destStart < curBestIndex {
				// Still have more lower destination data
				if sourceStart < sourceIndex {
					// Still have more lower source data -- recursive call to process lower indexes
					processRange(destStart, destEnd: curBestIndex - 1, sourceStart: sourceStart, sourceEnd: sourceIndex - 1)
				}
			}

			let upperDestStart = curBestIndex + length
			let upperSourceStart = sourceIndex + length
			if destEnd >= upperDestStart {
				// We still have more upper dest data
				if sourceEnd >= upperSourceStart {
					// Still have more upper source data -- recursive call to process upper indexes
					processRange(upperDestStart, destEnd: destEnd, sourceStart: upperSourceStart, sourceEnd: sourceEnd)
				}
			}

		case .NoMatch, .Unknown:
			// We are done - there are no matches in this span
			break
		}
	}
}

// ----------------------------------------------------------------------------
// MARK: Report

extension DiffEngine {
	private func findIntermediateChanges(curDest: Int, nextDest: Int, curSource: Int, nextSource: Int) -> [DiffResultSpan] {
		var curDest = curDest
		var curSource = curSource

		var changes = [DiffResultSpan]()
		let diffDest = nextDest - curDest
		let diffSource = nextSource - curSource

		if diffDest > 0 {
			if diffSource > 0 {
				let minDiff = min(diffDest, diffSource)
				changes.append(.Replace(sourceIndex: curSource, destIndex: curDest, length: minDiff))

				if diffDest > diffSource {
					curDest += minDiff
					changes.append(.Add(destIndex: curDest, length: diffDest - diffSource))
				} else {
					if diffSource > diffDest {
						curSource += minDiff
						changes.append(.Delete(sourceIndex: curSource, length: diffSource - diffDest))
					}
				}
			} else {
				changes.append(.Add(destIndex: curDest, length: diffDest))
			}
		} else {
			if diffSource > 0 {
				changes.append(.Delete(sourceIndex: curSource, length: diffSource))
			}
		}

		return changes
	}

	internal func diffReport() -> [DiffResultSpan] {
		var report = [DiffResultSpan]()
		let dcount = destList.endIndex
		let scount = sourceList.endIndex

		// Deal with the special case of empty files
		if dcount == 0 {
			if scount > 0 {
				report.append(.Delete(sourceIndex: 0, length: scount))
			}
			return report
		} else {
			if scount == 0 {
				report.append(.Add(destIndex: 0, length: dcount))
				return report
			}
		}

		matchList.sortInPlace(isOrderedBeforeByDestIndex)
		var curDest = 0
		var curSource = 0
		var maybeLast: DiffResultSpan? = nil

		// Process each match record
		for span in matchList {
			let nextDest = span.destIndex ?? 0
			let nextSource = span.sourceIndex ?? 0

			let changes = findIntermediateChanges(curDest, nextDest: nextDest, curSource: curSource, nextSource: nextSource)
			report += changes

			if let last = maybeLast where changes.isEmpty {
				maybeLast = last.addLength(length: span.length)
			} else {
				report.append(span)
			}

			curDest = nextDest + span.length
			curSource = nextSource + span.length
			maybeLast = span
		}

		// Process any tail end data
		report += findIntermediateChanges(curDest, nextDest: dcount, curSource: curSource, nextSource: scount)
		
		return report
	}
}
