import XCTest

final class PaperSprintUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    @MainActor
    func testQuizScoringAndHistory() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        app.buttons["quickPractice"].tap()
        XCTAssertFalse(app.buttons["checkAnswer"].isEnabled)
        // The original five-question Values lesson has this answer key.
        for answer in [1, 2, 1, 2, 3] {
            XCTAssertTrue(app.buttons["answer_\(answer)"].waitForExistence(timeout: 5))
            app.buttons["answer_\(answer)"].tap()
            let check = app.buttons["checkAnswer"]
            if !check.isHittable { app.swipeUp() }
            check.tap()
            let next = app.buttons["nextQuestion"]
            if !next.isHittable { app.swipeUp() }
            next.tap()
        }
        XCTAssertTrue(app.staticTexts["resultScore"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["resultScore"].label.contains("5 of 5"))
        let saved = app.descendants(matching: .any)["savedResult"].firstMatch
        if !saved.isHittable { app.swipeUp() }
        XCTAssertTrue(saved.waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        app.tabBars.buttons["Results"].tap()
        XCTAssertTrue(app.staticTexts["Values, Types & Optionals"].waitForExistence(timeout: 5))
    }
    @MainActor
    func testLessonNavigationAndSampleOCR() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        app.tabBars.buttons["Lessons"].tap()
        app.buttons["lesson_values"].tap()
        XCTAssertTrue(app.staticTexts["Constants and variables"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Scan"].tap()
        let scan = app.buttons["scanSample"]
        if !scan.isHittable { app.swipeUp() }
        scan.tap()
        let text = app.staticTexts["ocrText"]
        XCTAssertTrue(text.waitForExistence(timeout: 30))
        XCTAssertTrue(text.label.localizedCaseInsensitiveContains("Swift"))
    }
    @MainActor
    func testLaunchPerformance() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        measure(metrics: [XCTApplicationLaunchMetric()]) { app.launch() }
    }
}
