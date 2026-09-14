//
//  RecorderTopSheetModelTests.swift
//  LOGITTests
//
//  The recorder top sheet's fold rules: how the list's scroll opens and closes it, and how
//  measurements move its stops. These are the rules the old in-flow header kept breaking.
//

import XCTest

@testable import LOGIT

final class RecorderTopSheetModelTests: XCTestCase {
    private let actions: CGFloat = 70
    private let panel: CGFloat = 230

    /// A measured, bootstrapped sheet with the list at `offset`.
    private func makeSheet(offset: CGFloat = 0) -> RecorderTopSheetModel {
        let sheet = RecorderTopSheetModel()
        sheet.scrollDidChange(to: offset, isFrozen: false)
        sheet.closedHeight = 73
        sheet.containerDidMeasure(800)
        sheet.actionsDidMeasure(actions)
        sheet.panelDidMeasure(panel)
        return sheet
    }

    // MARK: - Bootstrap

    func testFreshWorkoutOpensAtTheActionsStop() {
        let sheet = makeSheet(offset: 0)
        XCTAssertEqual(sheet.reveal, actions)
        XCTAssertFalse(sheet.summaryIsRevealed, "The note must not be out when a workout starts")
    }

    func testResumedWorkoutScrolledIntoItsSetsOpensClosed() {
        let sheet = makeSheet(offset: 900)
        XCTAssertEqual(sheet.reveal, 0)
    }

    // MARK: - Scrolling

    func testScrollingDownFromTheTopFoldsInLockStep() {
        let sheet = makeSheet()
        sheet.scrollDidChange(to: 30, isFrozen: false)
        XCTAssertEqual(sheet.reveal, actions - 30)
        sheet.scrollDidChange(to: 200, isFrozen: false)
        XCTAssertEqual(sheet.reveal, 0)
    }

    func testScrollingBackToTheTopBringsTheActionsBack() {
        let sheet = makeSheet()
        sheet.scrollDidChange(to: 300, isFrozen: false)
        sheet.scrollDidChange(to: 20, isFrozen: false)
        XCTAssertEqual(sheet.reveal, actions - 20)
        sheet.scrollDidChange(to: 0, isFrozen: false)
        XCTAssertEqual(sheet.reveal, actions)
    }

    func testASmallScrollUpDeepInTheListBringsNothingBack() {
        let sheet = makeSheet()
        sheet.scrollDidChange(to: 600, isFrozen: false)
        sheet.scrollDidChange(to: 540, isFrozen: false)
        XCTAssertEqual(sheet.reveal, 0)
    }

    /// The reported bug: open the sheet mid-list, scroll down, and it must fold — never grow first.
    func testOpenedMidListScrollingDownOnlyEverFolds() {
        let sheet = makeSheet(offset: actions)
        XCTAssertEqual(sheet.reveal, 0)
        sheet.reveal = actions // opened by a tap
        var previous = sheet.reveal
        for offset in stride(from: actions + 5, through: actions + 120, by: 5) {
            sheet.scrollDidChange(to: offset, isFrozen: false)
            XCTAssertLessThanOrEqual(sheet.reveal, previous, "Expanded while scrolling down at offset \(offset)")
            previous = sheet.reveal
        }
        XCTAssertEqual(sheet.reveal, 0)
    }

    func testRubberBandingAtTheTopDoesNotFold() {
        let sheet = makeSheet()
        sheet.scrollDidChange(to: -40, isFrozen: false)
        sheet.scrollDidChange(to: -10, isFrozen: false)
        sheet.scrollDidChange(to: 0, isFrozen: false)
        XCTAssertEqual(sheet.reveal, actions)
    }

    func testBouncingAtTheBottomDoesNotReopen() {
        let sheet = makeSheet()
        sheet.scrollDidChange(to: 1_000, isFrozen: false)
        sheet.scrollDidChange(to: 1_060, isFrozen: false)
        sheet.scrollDidChange(to: 1_000, isFrozen: false)
        XCTAssertEqual(sheet.reveal, 0)
    }

    func testTheSummaryStopFoldsFromWhereverItIs() {
        let sheet = makeSheet()
        sheet.reveal = panel
        sheet.scrollDidChange(to: 100, isFrozen: false)
        XCTAssertEqual(sheet.reveal, panel - 100)
    }

    func testAFrozenOrDraggedSheetIgnoresTheScroll() {
        let sheet = makeSheet()
        sheet.scrollDidChange(to: 50, isFrozen: true)
        XCTAssertEqual(sheet.reveal, actions)
        sheet.isDragging = true
        sheet.scrollDidChange(to: 120, isFrozen: false)
        XCTAssertEqual(sheet.reveal, actions)
        sheet.isDragging = false
        // The baseline moved with the ignored scrolls, so letting go does not replay them.
        sheet.scrollDidChange(to: 125, isFrozen: false)
        XCTAssertEqual(sheet.reveal, actions - 5)
    }

    // MARK: - Measurement

    /// The first layout pass can measure the actions at a narrower width, taller. The sheet must stay
    /// at the actions stop as it settles, not keep the taller reveal and show the note.
    func testTheRestingStopSurvivesTheActionsBeingRemeasured() {
        let sheet = RecorderTopSheetModel()
        sheet.actionsDidMeasure(140)
        sheet.panelDidMeasure(300)
        XCTAssertEqual(sheet.reveal, 140)
        sheet.actionsDidMeasure(actions)
        sheet.panelDidMeasure(panel)
        XCTAssertEqual(sheet.reveal, actions)
        XCTAssertFalse(sheet.summaryIsRevealed)
    }

    func testLoggingTheFirstSetDoesNotGrowTheSheet() {
        let sheet = makeSheet()
        sheet.panelDidMeasure(panel + 80) // the tiles appear
        XCTAssertEqual(sheet.reveal, actions)
    }

    func testRestingAllTheWayOutStaysAllTheWayOut() {
        let sheet = makeSheet()
        sheet.reveal = panel
        sheet.panelDidMeasure(panel + 80)
        XCTAssertEqual(sheet.reveal, panel + 80)
    }

    // MARK: - Stops

    func testReleaseSnapsToTheNearestStopOrFlingsToTheNext() {
        let sheet = makeSheet()
        XCTAssertEqual(sheet.stops, [0, actions, panel])
        XCTAssertEqual(sheet.stop(nearestTo: 50, velocity: 0), actions)
        XCTAssertEqual(sheet.stop(nearestTo: 50, velocity: 900), actions, "A fling goes one stop on, not to the end")
        XCTAssertEqual(sheet.stop(nearestTo: 100, velocity: 900), panel)
        XCTAssertEqual(sheet.stop(nearestTo: 50, velocity: -900), 0)
        XCTAssertEqual(sheet.stop(nearestTo: 200, velocity: 0), panel)
        XCTAssertEqual(sheet.stop(nearestTo: 200, velocity: -900), actions)
    }

    func testTheFinishStopRunsToTheBottomOfTheContainer() {
        let sheet = makeSheet()
        XCTAssertEqual(sheet.fullReveal, 800 - 73)
    }

    func testRubberBandStretchesPastTheLastStopButNeverAboveTheRow() {
        XCTAssertEqual(RecorderTopSheetModel.rubberBand(-20, upper: panel), 0)
        XCTAssertEqual(RecorderTopSheetModel.rubberBand(100, upper: panel), 100)
        let stretched = RecorderTopSheetModel.rubberBand(panel + 200, upper: panel)
        XCTAssertGreaterThan(stretched, panel)
        XCTAssertLessThan(stretched, panel + 40)
    }
}
