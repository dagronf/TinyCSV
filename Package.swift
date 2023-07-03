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
			dependencies: []),
		.testTarget(
			name: "TinyCSVTests",
			dependencies: ["TinyCSV"],
			resources: [
				.process("resources"),
			]
		),
	]
)
