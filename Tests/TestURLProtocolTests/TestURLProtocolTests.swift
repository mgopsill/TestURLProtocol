#if canImport(Combine)
import TestURLProtocol
import XCTest

final class TestURLProtocolTests: XCTestCase {
	private let url = URL(string: "https://www.google.com")!
	private var request: URLRequest { .init(url: url) }

	override class func setUp() {
		super.setUp()
		URLProtocol.registerClass(TestURLProtocol.self)
	}

	override class func tearDown() {
		super.tearDown()
		URLProtocol.unregisterClass(TestURLProtocol.self)
	}

	override func tearDown() {
		super.tearDown()
		TestURLProtocol.mockResponses.removeAll()
	}

	func test_canInit_withURL_withMockedResponse() {
		TestURLProtocol.mockResponses[url] = { _ in return (.success(Data()), nil) }
		XCTAssertTrue(TestURLProtocol.canInit(with: request))
	}

	func test_cannotInit_withURL_withoutMockedResponse() {
		XCTAssertFalse(TestURLProtocol.canInit(with: request))
	}

	func test_cannotInit_withMismatchingURLs_withoutMockedResponse() {
		let otherURL = URL(string: "https://www.two.com")!
		TestURLProtocol.mockResponses[url] = { _ in return (.success(Data()), nil) }
		XCTAssertFalse(TestURLProtocol.canInit(with: URLRequest(url: otherURL)))
	}

	func test_canonicalRequest() {
		XCTAssertEqual(TestURLProtocol.canonicalRequest(for: request), request)
	}

	@available(iOS 13.0, *)
	func test_successfulResponse() {
		TestURLProtocol.mockResponses[url] = { request in
			(result: .success(Data()), statusCode: 200)
		}

		let expectation = XCTestExpectation()
		let cancellable = URLSession.shared.dataTaskPublisher(for: url)
			.sink(receiveCompletion: { _ in }) { (data, response) in
				expectation.fulfill()
			}
		wait(for: [expectation], timeout: 0.2)
	}

	@available(iOS 13.0, *)
	func test_failedResponse() {
		struct TestError: Error {}
		TestURLProtocol.mockResponses[url] = { request in
			(result: .failure(TestError()), statusCode: 200)
		}

		let expectation = XCTestExpectation()
		let cancellable = URLSession.shared.dataTaskPublisher(for: url)
			.sink { completion in
				switch completion {
				case .failure:
					expectation.fulfill()
				case .finished: break
				}
			} receiveValue: { _ in
			}

		wait(for: [expectation], timeout: 0.2)
	}
}
#endif
