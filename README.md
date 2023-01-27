# 🕸 TestURLProtocol
[![CI](https://github.com/mgopsill/TestURLProtocol/workflows/CI/badge.svg)](https://github.com/mgopsill/TestURLProtocol/actions?query=workflow%3ACI)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmgopsill%2FTestURLProtocol%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/mgopsill/TestURLProtocol)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmgopsill%2FTestURLProtocol%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/mgopsill/TestURLProtocol)
![GitHub](https://img.shields.io/github/license/mgopsill/testurlprotocol)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)

The TestURLProtocol is a URLProtocol subclass for testing purposes. It allows for setting mock responses for specific URLs, which are returned instead of making a real network request. This can be very useful for testing your app's networking code without relying on external resources or APIs.

## Usage

To use the TestURLProtocol, you first need to register it with the `URLProtocol`:

```swift 
URLProtocol.registerClass(TestURLProtocol.self)
```

Once you've registered the TestURLProtocol, you can set mock responses for specific URLs by adding them to the mockResponses dictionary. Here's an example of how to do that:

```
TestURLProtocol.mockResponses[url] = { request in
    (Result.success(data), statusCode)
}
```

The mockResponses dictionary takes a closure that takes in a URLRequest and returns a tuple containing a Result of Data or Error, and an optional statusCode.


## Example Network Test Case Setup

Typically, one unit test class might test network-related code. In that case a setup might look like the following.

```swift
final class NetworkingTest: XCTestCase {
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
}
```

## Different Session

If you are using a custom `URLSessionConfiguration` you can register the protocol like so:

```swift
let config = URLSessionConfiguration.default
config.protocolClasses = [TestURLProtocol.self]
let session = URLSession(configuration: config)
```

### Note

It is important to note that TestURLProtocol will only work for URLs that have been registered in the mockResponses dictionary. If a request is made for a URL that hasn't been registered, the TestURLProtocol will not handle the request and it will be passed on to the next registered URLProtocol.

Also, if you have registered the TestURLProtocol you have to make sure that it's the first registered class in the protocolClasses array, otherwise the URLSession will use the next protocol in the list to handle the request.