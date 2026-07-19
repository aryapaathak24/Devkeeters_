//
//  Devkeeters_26UITests.swift
//  Devkeeters_26UITests
//
//  Created by arya pathak on 18/07/26.
//

import XCTest

final class Devkeeters_26UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testMyUsualOrderFlow() throws {
        let app = XCUIApplication()
        app.launch()

        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 5) {
            skipButton.tap()
        }

        let attach1 = XCTAttachment(screenshot: app.screenshot())
        attach1.name = "01_home"
        attach1.lifetime = .keepAlways
        add(attach1)

        let field = app.textFields["e.g. butter chicken and naan"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "order text field should exist")
        field.tap()
        field.typeText("butter chicken and naan")

        let orderButton = app.buttons["Order with Cortex"]
        XCTAssertTrue(orderButton.exists)
        orderButton.tap()

        let orderAgainButton = app.buttons["Order Again"]
        XCTAssertTrue(orderAgainButton.waitForExistence(timeout: 10), "My Usual card with Order Again should appear after placing order")

        let attach2 = XCTAttachment(screenshot: app.screenshot())
        attach2.name = "02_after_first_order"
        attach2.lifetime = .keepAlways
        add(attach2)

        orderAgainButton.tap()

        let attach3 = XCTAttachment(screenshot: app.screenshot())
        attach3.name = "03_after_order_again_tap"
        attach3.lifetime = .keepAlways
        add(attach3)

        sleep(3)

        let attach4 = XCTAttachment(screenshot: app.screenshot())
        attach4.name = "04_tracking_state"
        attach4.lifetime = .keepAlways
        add(attach4)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
