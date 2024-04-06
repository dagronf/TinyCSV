// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "TinyCSV",
	products: [
		.library(
			name: "TinyCSV",
			targets: ["TinyCSV"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "TinyCSV",
			dependencies: [],
			resources: [
				.copy("PrivacyInfo.xcprivacy"),
			]
		),
		.testTarget(
			name: "TinyCSVTests",
			dependencies: ["TinyCSV"],
			resources: [
				.process("resources"),
			]
		),
	]
)
