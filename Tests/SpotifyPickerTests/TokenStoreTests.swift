import Foundation
import XCTest

@testable import SpotifyPicker

class TokenStoreTests: XCTestCase {
	private let accessToken = "awesomeToken"
	private let store = TokenStore(userDefaultsKey: "awesomeKey")

	override func setUp() {
		super.setUp()
		UserDefaults.standard.removeObject(forKey: "awesomeKey")
	}

	func test_currentToken_withInitialState_shouldBeNil() {
		XCTAssertNil(store.currentToken)
	}

	func test_currentToken_whenPersist_shouldReturnToken() {
		store.persist(token: accessToken, expiresInSeconds: 1)
		XCTAssertEqual(store.currentToken, accessToken)
	}

	func test_currentToken_whenPersistAndWaitFor2Secs_shouldReturnNil() {
		store.persist(token: accessToken, expiresInSeconds: 1)
		XCTAssertEqual(store.currentToken, accessToken)

		let expectation = XCTestExpectation(description: "waiting 2 seconds")
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			expectation.fulfill()
		}

		wait(for: [expectation])
		XCTAssertNil(store.currentToken)
	}

	func test_currentToken_whenPersistFor5SecsAndWaitFor2Secs_shouldReturnToken() {
		store.persist(token: accessToken, expiresInSeconds: 5)
		XCTAssertEqual(store.currentToken, accessToken)

		let expectation = XCTestExpectation(description: "waiting 2 seconds")
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			expectation.fulfill()
		}

		wait(for: [expectation])
		XCTAssertEqual(store.currentToken, accessToken)
	}

	func test_currentToken_whenPersistFor0sec_shouldReturnNil() {
		store.persist(token: accessToken, expiresInSeconds: 0)
		XCTAssertNil(store.currentToken)
	}

	func test_currentToken_whenPersistForNegativeSeconds_shouldReturnNil() {
		store.persist(token: accessToken, expiresInSeconds: -1)
		XCTAssertNil(store.currentToken)
	}

	func test_securedCurrentToken_whenPersist_shouldNotBeEqualToToken() {
		store.persist(token: accessToken, expiresInSeconds: 10)

		let lookup = UserDefaults.standard.string(forKey: "awesomeKey")
		XCTAssertTrue(lookup != accessToken)

		// base64 encoded version of "awesomeToken"
		XCTAssertEqual(lookup, "YXdlc29tZVRva2Vu")
	}
}
