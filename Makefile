PLATFORM_IOS = iOS Simulator,name=iPhone 14
PLATFORM_MACOS = macOS
PLATFORM_WATCHOS = watchOS Simulator,name=Apple Watch Series 7 (45mm)

test:
	swift test
	xcodebuild test \
		-scheme TestURLProtocol \
		-destination platform="$(PLATFORM_IOS)"
	xcodebuild test \
		-scheme TestURLProtocol \
		-destination platform="$(PLATFORM_MACOS)"
	xcodebuild build \
		-scheme TestURLProtocol \
		-destination platform="$(PLATFORM_WATCHOS)"

format:
	swift format --in-place --configuration .swift-format.json --recursive ./Package.swift ./Sources ./Tests
