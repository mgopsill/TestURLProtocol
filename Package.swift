// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "TestURLProtocol",
	products: [
		.library(
			name: "TestURLProtocol",
			targets: ["TestURLProtocol"]
		)
	],
	dependencies: [],
	targets: [
		.target(
			name: "TestURLProtocol",
			dependencies: []
		),
		.testTarget(
			name: "TestURLProtocolTests",
			dependencies: ["TestURLProtocol"]
		),
	]
)
