//
//  LiveActivityScreenshots.swift
//  LOGITUITests
//
//  Captures the compact island, expanded island and Lock Screen presentations for each fixture in
//  `WorkoutLiveActivityFixture`. (The minimal presentation only appears beside another app's
//  activity, which a single-app test can't stage — check it in the widget's Xcode preview.) The app is launched with
//  `-UITEST_LIVE_ACTIVITY <fixture>`, which starts the activity with exactly that state instead of
//  mirroring the recorder, so no workout has to be driven.
//
//  Run on the iOS 26.4 simulator (the 26.0 test runner dies nondeterministically):
//      xcodebuild test -workspace LOGIT.xcworkspace -scheme LOGITScreenshots \
//        -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
//        -only-testing:LOGITUITests/LiveActivityScreenshots \
//        -resultBundlePath liveactivity.xcresult
//      xcrun xcresulttool export attachments --path liveactivity.xcresult --output-path <dir>
//
//  Attachments are named `la_<fixture>_<presentation>`. One launch per test method — relaunching
//  within a method kills the iOS 26 test runner.
//

import XCTest

@MainActor
final class LiveActivityScreenshots: XCTestCase {
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    private static var hasLaunched = false

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
    }

    func testTemplateSet() { capture("templateSet") }
    func testWeightEntered() { capture("weightEntered") }
    func testSuperset() { capture("superset") }
    func testDropSetLongName() { capture("dropSetLongName") }
    func testEmptyWorkout() { capture("emptyWorkout") }
    func testRestTimer() { capture("restTimer") }
    func testRestTimerPaused() { capture("restTimerPaused") }
    func testRestStopwatch() { capture("restStopwatch") }
    func testLastSetRest() { capture("lastSetRest") }
    func testManualTimer() { capture("manualTimer") }
    func testManualStopwatch() { capture("manualStopwatch") }

    /// The real path, no fixture: the recorder's curated Push Day with a rest timer running, mirrored
    /// into the activity by `WorkoutLiveActivityManager` exactly as in a workout.
    func testRecorderDrivenRestTimer() {
        capture("recorder", arguments: [
            "-UITEST_FIXTURES", "1",
            "-UITEST_SHOW_RECORDER", "1",
            "-UITEST_START_REST_TIMER",
        ])
    }

    /// Rest timer ticking in the island and on the Lock Screen, for a screen recording taken around
    /// this test (`simctl io recordVideo`): holds each presentation long enough to see it count.
    func testRestTimerRecording() {
        launch(["-UITEST_LIVE_ACTIVITY", "restTimer"])
        XCUIDevice.shared.press(.home)
        sleep(4)
        expandIsland()
        sleep(5)
        XCUIDevice.shared.press(.home)
        sleep(2)
        lock()
        sleep(6)
        unlock()
    }

    // MARK: - Steps

    private func capture(_ fixture: String, arguments: [String]? = nil) {
        launch(arguments ?? ["-UITEST_LIVE_ACTIVITY", fixture])
        attach("la_\(fixture)_0_app")

        XCUIDevice.shared.press(.home)
        sleep(3)
        attach("la_\(fixture)_1_compact")

        expandIsland()
        sleep(2)
        attach("la_\(fixture)_2_expanded")
        XCUIDevice.shared.press(.home)
        sleep(2)

        lock()
        sleep(3)
        attach("la_\(fixture)_3_lockscreen")
        unlock()
    }

    private func launch(_ arguments: [String]) {
        let app = XCUIApplication(bundleIdentifier: ".com.lukaskbl.LOGIT")
        app.launchArguments = arguments + [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launch()
        // The fixture is requested once the app is active (the recorder path mirrors its workout as
        // soon as it loads). Leaving the app earlier suspends it before the request goes out — and the
        // first launch after the test run installs the app is slow (default exercises load), so it
        // gets longer.
        sleep(Self.hasLaunched ? 5 : 15)
        Self.hasLaunched = true
    }

    /// A long press on the Dynamic Island opens the expanded presentation.
    private func expandIsland() {
        springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.028))
            .press(forDuration: 1.2)
    }

    /// Locks, then wakes the display without unlocking so the Lock Screen renders.
    private func lock() {
        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        sleep(2)
        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        sleep(2)
        // A fresh simulator asks once, under the first activity, whether LOGIT may keep showing them.
        for title in ["Always Allow", "Allow"] {
            let button = springboard.buttons[title]
            if button.waitForExistence(timeout: 1) {
                button.tap()
                sleep(1)
                break
            }
        }
    }

    private func unlock() {
        XCUIDevice.shared.press(.home)
        sleep(1)
        XCUIDevice.shared.press(.home)
        sleep(1)
    }

    private func attach(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
