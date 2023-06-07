//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Aleksandr Velikanov on 03.06.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testViewController() {
        let modulesFactory = ModulesFactory()
        let trackerListModule = modulesFactory.makeTrackersView()
        guard let trackerListView = trackerListModule.view.toPresent() else { return }
        assertSnapshot(matching: trackerListView, as: .image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(matching: trackerListView, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
}
