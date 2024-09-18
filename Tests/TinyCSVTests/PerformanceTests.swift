import XCTest
import Foundation
@testable import TinyCSV


final class PerformanceTests: XCTestCase {

	func measureTime(_ closure: () -> Void) {
		// Unfortunately Linux does not have the `XCTMeasureOptions` to run a test multiple times and measure the time
		let start = Date()
		closure()
		let diff = Date().timeIntervalSince(start)
		print("\(self.name) -> Took \(diff) seconds")
	}

	func testPerformance1() throws {
		let text = try loadCSV(name: "organizations-1000", extn: "csv")
		self.measureTime {
			for _ in 0 ..< 100 {
				let _ = TinyCSV.Coder().decode(text: text)
			}
		}
	}

	func testPerformance2() throws {
		let text = try loadCSV(name: "imdb_top_1000", extn: "csv")
		self.measureTime {
			for _ in 0 ..< 10 {
				let _ = TinyCSV.Coder().decode(text: text)
			}
		}
	}
}
