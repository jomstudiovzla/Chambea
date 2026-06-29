import XCTest

final class ChambeaUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingAndSearchTab() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        if app.buttons["Next"].exists || app.buttons["Siguiente"].exists {
            let next = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'next' OR label CONTAINS[c] 'siguiente'")).firstMatch
            if next.exists { next.tap() }
        }

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
}