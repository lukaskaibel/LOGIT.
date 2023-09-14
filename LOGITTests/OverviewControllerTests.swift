//
//  OverviewControllerTests.swift
//  LOGITTests
//
//  Created by Lukas Kaibel on 14.09.23.
//

import XCTest
@testable import LOGIT

final class OverviewControllerTests: XCTestCase {

    private let overviewController = OverviewController.preview

    func testExerciseDetailOverviewItemCollection() {
        let items = overviewController.exerciseDetailOverviewItemCollection.items
        let types = items.map { $0.type }
        XCTAssertEqual(types.contains(OverviewItem.ItemType.personalBest), true, "OverviewItem 'personalBest' not in collection.items.")
        XCTAssertEqual(types.contains(OverviewItem.ItemType.bestWeightPerDay), true, "OverviewItem 'bestWeightPerDay' not in collection.items.")
        XCTAssertEqual(types.contains(OverviewItem.ItemType.bestRepetitionsPerDay), true, "OverviewItem 'bestRepetitionsPerDay' not in collection.items.")
    }
    
    func testHomeScreenOverviewItemCollection() {
        let items = overviewController.homeScreenOverviewItemCollection.items
        let types = items.map { $0.type }
        XCTAssertEqual(types.contains(OverviewItem.ItemType.targetPerWeek), true, "OverviewItem 'targetPerWeek' not in collection.items.")
        XCTAssertEqual(types.contains(OverviewItem.ItemType.muscleGroupsInLastTen), true, "OverviewItem 'muscleGroupsInLastTen' not in collection.items.")
    }

}
