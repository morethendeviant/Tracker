//
//  DiffableDataSource.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 24.04.2023.
//

import UIKit

final class CategoriesDiffableDataSource: UITableViewDiffableDataSource<Int, String> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
        
    init(_ tableView: UITableView,
         dataSourceProvider: CategoriesDataSourceProvider,
         interactionDelegate: UIContextMenuInteractionDelegate? = nil) {

        super.init(tableView: tableView) { _, _, itemIdentifier in
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.backgroundColor = .ypBackground
            cell.selectionStyle = .none
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.text = itemIdentifier
            
            if let selectedCategory = dataSourceProvider.selectedCategory,
               let text = cell.textLabel?.text,
               selectedCategory == text {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            if let interactionDelegate {
                cell.contentView.addInteraction(UIContextMenuInteraction(delegate: interactionDelegate))
            }
            
            return cell
        }
    }
    
    func reload(_ data: [String], animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        apply(snapshot, animatingDifferences: animated)
    }
}
