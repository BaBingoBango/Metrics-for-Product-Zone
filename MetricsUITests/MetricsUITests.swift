//
//  MetricsUITests.swift
//  MetricsUITests
//
//  Created by Ethan Marshall on 7/30/21.
//

import XCTest

/// Walks the main screens and attaches a screenshot of each, which doubles as a smoke test of the
/// controls' accessibility labels.
///
/// Run it on the simulators whose sizes App Store Connect wants, then export the attachments:
/// `xcrun xcresulttool export attachments --path Results.xcresult --output-path Screenshots`.
/// The app launches with sample data, and with the Sharing section hidden when the `HIDE_SHARING`
/// environment variable is set, since sharing needs an iCloud account.
final class ScreenshotTests: XCTestCase {
    private var app: XCUIApplication!
    private var deviceName = ""

    override func setUpWithError() throws {
        continueAfterFailure = false
        deviceName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? "device"
        app = XCUIApplication()
        let hideSharing = ProcessInfo.processInfo.environment["HIDE_SHARING"] != nil
        app.launchArguments = ["-showSharingInTodayView", hideSharing ? "0" : "1", "-seedSampleData"]
        app.launch()
    }

    func testCaptureMainScreens() throws {
        snapshot("today")

        app.buttons["Log Transaction"].firstMatch.tap()
        app.buttons["iPhone"].firstMatch.tap()
        app.buttons["AppleCare+"].firstMatch.tap()
        app.buttons["Trade-In"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 5))
        snapshot("log-transaction")
        app.buttons["Cancel"].firstMatch.tap()

        app.buttons["This Week"].firstMatch.tap()
        let appleCareCard = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'AppleCare+'")).firstMatch
        XCTAssertTrue(appleCareCard.waitForExistence(timeout: 5))
        snapshot("this-week")

        appleCareCard.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        snapshot("graph-detail")
        app.buttons["Done"].firstMatch.tap()

        app.buttons["Lifetime"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Lifetime"].waitForExistence(timeout: 5))
        snapshot("lifetime")
    }

    /// Captures the Sharing section on a simulator signed into an account that someone shares with.
    func testCaptureSharing() throws {
        try XCTSkipIf(ProcessInfo.processInfo.environment["CAPTURE_SHARING"] == nil, "Set CAPTURE_SHARING to run.")
        // The Sharing cards sit in a lazy grid below the fold, so scroll before waiting for one to load.
        app.swipeUp()
        app.swipeUp()
        let person = app.buttons.matching(NSPredicate(format: "label CONTAINS 'AppleCare+'")).element(boundBy: 0)
        XCTAssertTrue(person.waitForExistence(timeout: 30))
        snapshot("sharing")
    }

    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "\(deviceName)-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
