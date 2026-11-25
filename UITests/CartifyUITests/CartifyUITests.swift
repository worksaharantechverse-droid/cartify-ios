import XCTest

final class CartifyUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITestMock", "-UITestReset"]
        app.launch()
    }

    func testShopGridAndSearch() {
        XCTAssertTrue(app.collectionViews["product-grid"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.cells["product-cell-p01"].exists)
        XCTAssertTrue(app.searchFields["product-search"].exists)
        XCTAssertTrue(app.buttons["category-filter"].exists)
    }

    func testAddProductAndOpenCart() {
        XCTAssertTrue(app.buttons["add-p01"].waitForExistence(timeout: 5))
        app.buttons["add-p01"].tap()
        app.buttons["Cart"].tap()
        XCTAssertTrue(app.tables["cart-table"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.cells["cart-row-p01"].exists)
        XCTAssertTrue(app.buttons["checkout-button"].exists)
    }

    func testPromoAndTotalsExist() {
        app.buttons["Cart"].tap()
        XCTAssertTrue(app.textFields["promo-field"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["apply-promo"].exists)
        XCTAssertTrue(app.staticTexts["subtotal-value"].exists)
        XCTAssertTrue(app.staticTexts["discount-value"].exists)
        XCTAssertTrue(app.staticTexts["total-value"].exists)
    }
}
