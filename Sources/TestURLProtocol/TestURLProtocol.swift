import Foundation

/// A `URLProtocol` subclass for testing purposes.
/// Allows for setting mock responses for specific URLs, which are returned instead of making a real network request.
public final class TestURLProtocol: URLProtocol {
	/// A type alias for a closure that takes in a `URLRequest` and returns a tuple containing a `Result` of `Data` or `Error`, and an optional `statusCode`.
	public typealias MockResponse = (URLRequest) -> (
		result: Result<Data, Error>, statusCode: Int?
	)
	/// A dictionary storing the mock responses for specific URLs.
	public static var mockResponses: [URL: MockResponse] = [:]

	public override class func canInit(with request: URLRequest) -> Bool {
		guard let url = request.url else { return false }
		return mockResponses.keys.contains(url.removingQueries)
	}

	public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	public override func startLoading() {
		guard
			let responseBlock = TestURLProtocol.mockResponses[
				request.url!.removingQueries
			]
		else { fatalError("No mock response") }
		let response = responseBlock(request)

		if let statusCode = response.statusCode {
			let httpURLResponse = HTTPURLResponse(
				url: request.url!,
				statusCode: statusCode,
				httpVersion: nil,
				headerFields: nil
			)!
			self.client?.urlProtocol(
				self,
				didReceive: httpURLResponse,
				cacheStoragePolicy: .notAllowed
			)
		}

		switch response.result {
		case let .success(data):
			client?.urlProtocol(self, didLoad: data)
			client?.urlProtocolDidFinishLoading(self)

		case let .failure(error):
			client?.urlProtocol(self, didFailWithError: error)
		}
	}

	public override func stopLoading() {}
}

extension URL {
	var removingQueries: URL {
		if var components = URLComponents(string: absoluteString) {
			components.query = nil
			return components.url ?? self
		}
		else {
			return self
		}
	}
}
