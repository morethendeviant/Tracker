//
//  DiffableDataSource.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 24.04.2023.
//

import UIKit

final class CategoriesDiffableDataSource: UITableViewDiffableDataSource<Int, CategoryCellModel> {
    
    init(_ tableView: UITableView, interactionDelegate: UIContextMenuInteractionDelegate? = nil) {
        
        super.init(tableView: tableView) { [weak interactionDelegate] _, _, itemIdentifier in
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.backgroundColor = Asset.ypBackground.color
            cell.selectionStyle = .none
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.text = itemIdentifier.name
            cell.accessoryType = itemIdentifier.isSelected ? .checkmark : .none
            
            if let interactionDelegate {
                cell.contentView.addInteraction(UIContextMenuInteraction(delegate: interactionDelegate))
            }
            
            return cell
        }
    }
    
    func reload(_ data: [CategoryCellModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        apply(snapshot, animatingDifferences: animated)
    }
}
                                              
struct CategoryCellModel: Hashable {
    let name: String
    let isSelected: Bool
}
