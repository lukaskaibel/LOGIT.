//
//  OverviewControllerTests.swift
//  LOGITTests
//
//  Created by Lukas Kaibel on 14.09.23.
//

import XCTest
@testable import LOGIT

final class OverviewControllerTests: XCTestCase {

    private let overviewController = WidgetController.preview

    func testExerciseDetailWidgetCollection() {
        let items = overviewController.exerciseDetailWidgetCollection.items
        let types = items.map { $0.type }
        XCTAssertEqual(types.contains(WidgetType.personalBest), true, "Widget 'personalBest' not in collection.items.")
        XCTAssertEqual(types.contains(WidgetType.bestWeightPerDay), true, "Widget 'bestWeightPerDay' not in collection.items.")
        XCTAssertEqual(types.contains(WidgetType.bestRepetitionsPerDay), true, "Widget 'bestRepetitionsPerDay' not in collection.items.")
    }
    
    func testHomeScreenWidgetCollection() {
        let items = overviewController.homeScreenWidgetCollection.items
        let types = items.map { $0.type }
        XCTAssertEqual(types.contains(WidgetType.targetPerWeek), true, "Widget 'targetPerWeek' not in collection.items.")
        XCTAssertEqual(types.contains(WidgetType.muscleGroupsInLastTen), true, "Widget 'muscleGroupsInLastTen' not in collection.items.")
    }

}
