// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SpotifyPicker",
	platforms: [
		.iOS(.v15),
	],
	products: [
		.library(name: "SpotifyPicker", targets: [
			"SpotifyPicker",
		]),
	],
	dependencies: [],
	targets: [
		.target(name: "SpotifyPicker"),
		.testTarget(name: "SpotifyPickerTests", dependencies: [
			"SpotifyPicker",
		]),
	]
)
