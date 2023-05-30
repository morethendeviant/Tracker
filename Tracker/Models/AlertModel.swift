//
//  AlertModel.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 30.05.2023.
//

import Foundation

struct AlertModel {
    let alertText: String
    let alertActions: [AlertAction]
}

struct AlertAction {
    let actionText: String
    let actionRole: ActionRole
    let action: (() -> Void)?
}

enum ActionRole {
    case regular, destructive, cancel
}
