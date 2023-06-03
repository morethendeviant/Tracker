//
//  DiffableDataSource.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 01.06.2023.
//

import UIKit

final class StatisticsDiffableDataSource: UITableViewDiffableDataSource<Int, StatisticsModel> {
        
    init(_ tableView: UITableView, interactionDelegate: UIContextMenuInteractionDelegate? = nil) {
        
        super.init(tableView: tableView) { tableView, _, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.identifier) as? StatisticsTableViewCell else { return UITableViewCell() }
            cell.model = itemIdentifier
            return cell
        }
    }
    
    func reload(_ data: [StatisticsModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        apply(snapshot, animatingDifferences: animated)
    }
}
                                              
struct StatisticsModel: Hashable {
    let number: String
    let title: String
}