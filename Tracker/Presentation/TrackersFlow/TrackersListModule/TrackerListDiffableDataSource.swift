//
//  TrackerListDiffableDataSource.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 26.04.2023.
//

import UIKit

final class TrackerListDiffableDataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>
    var snapshot = Snapshot()
    
    init(_ collectionView: UICollectionView,
         dataSourceProvider: TrackersDataSourceProvider,
         interactionDelegate: UIContextMenuInteractionDelegate? = nil) {
        
        super.init(collectionView: collectionView) { collectionView, indexPath, tracker in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
                fatalError("cell not found")
            }
            
            cell.color = Colors[tracker.color]
            cell.emoji = Emojis[tracker.emoji]
            cell.trackerText = tracker.name
            cell.callback = {
                dataSourceProvider.changeStateForTracker(tracker)
            }
            
            cell.isMarked = dataSourceProvider.cellIsMarkedWithId(tracker.id)
            cell.daysAmount = dataSourceProvider.daysAmountWithId(tracker.id)
            cell.interactionDelegate = interactionDelegate
            
            return cell
        }
    }
    
    func reloadAll(_ data: [TrackerCategory], animated: Bool = true) {
        snapshot.deleteAllItems()
        snapshot.appendSections(data)
        data.forEach { category in
            snapshot.appendItems(category.trackers, toSection: category)
        }
        
        apply(snapshot, animatingDifferences: animated)
    }
        
    func reloadTracker(_ tracker: Tracker, animated: Bool = true) {
        var singleSnapshot = snapshot
        singleSnapshot.reloadItems([tracker])
        apply(singleSnapshot)
    }
}
