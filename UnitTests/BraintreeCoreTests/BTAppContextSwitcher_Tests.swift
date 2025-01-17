import XCTest
@testable import BraintreeCore

class BTAppContextSwitcher_Tests: XCTestCase {
    var appSwitch = BTAppContextSwitcher.shared

    override func setUp() {
        super.setUp()
        appSwitch = BTAppContextSwitcher.shared
    }

    override func tearDown() {
        MockAppContextSwitchClient.cannedCanHandle = false
        MockAppContextSwitchClient.lastCanHandleURL = nil
        MockAppContextSwitchClient.lastHandleReturnURL = nil
        super.tearDown()
    }

    func testSetReturnURLScheme() {
        BTAppContextSwitcher.shared.returnURLScheme = "com.some.scheme"
        XCTAssertEqual(appSwitch.returnURLScheme, "com.some.scheme")
    }

    func testHandleOpenURL_whenClientIsRegistered_invokesCanHandleReturnURL() {
        appSwitch.register(MockAppContextSwitchClient.self)
        let expectedURL = URL(string: "fake://url")!

        BTAppContextSwitcher.shared.handleOpen(expectedURL)

        XCTAssertEqual(MockAppContextSwitchClient.lastCanHandleURL!, expectedURL)
    }

    func testHandleOpenURL_whenClientCanHandleOpenURL_invokesHandleReturnURL_andReturnsTrue() {
        appSwitch.register(MockAppContextSwitchClient.self)
        MockAppContextSwitchClient.cannedCanHandle = true
        let expectedURL = URL(string: "fake://url")!

        let handled = BTAppContextSwitcher.shared.handleOpen(expectedURL)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppContextSwitchClient.lastHandleReturnURL!, expectedURL)
    }

    func testHandleOpenURL_whenClientCantHandleOpenURL_doesNotInvokeHandleReturnURL_andReturnsFalse() {
        appSwitch.register(MockAppContextSwitchClient.self)
        MockAppContextSwitchClient.cannedCanHandle = false

        let handled = BTAppContextSwitcher.shared.handleOpen(URL(string: "fake://url")!)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppContextSwitchClient.lastHandleReturnURL)
    }

    func testHandleOpenURL_withNoAppSwitching_returnsFalse() {
        let handled = BTAppContextSwitcher.shared.handleOpen(URL(string: "scheme://")!)
        XCTAssertFalse(handled)
    }
    
    func testHandleOpenURLContext_whenClientCanHandleOpenURL_invokesHandleReturnURL_andReturnsTrue() {
        appSwitch.register(MockAppContextSwitchClient.self)
        MockAppContextSwitchClient.cannedCanHandle = true

        let mockURLContext = BTMockOpenURLContext(url: URL(string: "my-url.com")!).mock

        let handled = BTAppContextSwitcher.shared.handleOpenURL(context: mockURLContext)

        XCTAssertTrue(handled)
        XCTAssertEqual(MockAppContextSwitchClient.lastCanHandleURL, URL(string: "my-url.com"))
        XCTAssertEqual(MockAppContextSwitchClient.lastHandleReturnURL, URL(string: "my-url.com"))
    }

    func testHandleOpenURLContext_whenClientCantHandleOpenURL_doesNotInvokeHandleReturnURL_andReturnsFalse() {
        appSwitch.register(MockAppContextSwitchClient.self)
        MockAppContextSwitchClient.cannedCanHandle = false

        let mockURLContext = BTMockOpenURLContext(url: URL(string: "fake://url")!).mock

        let handled = BTAppContextSwitcher.shared.handleOpenURL(context: mockURLContext)

        XCTAssertFalse(handled)
        XCTAssertNil(MockAppContextSwitchClient.lastHandleReturnURL)
    }
        
    func testHandleOpenURLContext_withNoAppSwitching_returnsFalse() {
        let mockURLContext = BTMockOpenURLContext(url: URL(string: "fake://url")!).mock
        let handled = BTAppContextSwitcher.shared.handleOpenURL(context: mockURLContext)
        XCTAssertFalse(handled)
    }

}

@objcMembers class MockAppContextSwitchClient: BTAppContextSwitchClient {
    static var cannedCanHandle = false
    static var lastCanHandleURL: URL?
    static var lastHandleReturnURL: URL?

    static func canHandleReturnURL(_ url: URL) -> Bool {
        lastCanHandleURL = url
        return cannedCanHandle
    }

    static func handleReturnURL(_ url: URL) {
        lastHandleReturnURL = url
    }
}
