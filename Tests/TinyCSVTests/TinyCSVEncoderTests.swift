import XCTest
@testable import TinyCSV

final class TinyCSVEncoderTests: XCTestCase {

	func testBasic() {
		let cells = [["cat", "dog"], ["fish", "chips"]]
		let parser = TinyCSV.Coder()
		let str = parser.encode(csvdata: cells)
		XCTAssertEqual(str, "\"cat\",\"dog\"\r\n\"fish\",\"chips\"\r\n")
	}

	func testBasic2() {
		let cells = [["This \"cat\" is bonkers", "dog"], ["fish", "chips"]]
		let parser = TinyCSV.Coder()
		let str = parser.encode(csvdata: cells)

		// Should be "This ""cat"" is bonkers","dog"
		XCTAssertEqual(str, "\"This \"\"cat\"\" is bonkers\",\"dog\"\r\n\"fish\",\"chips\"\r\n")
	}

	func testBasic3() {
		let cells = [["aaa", "b \r\nbb", "ccc"], ["zzz", "yyy", "xxx"]]

		let parser = TinyCSV.Coder()
		let str = parser.encode(csvdata: cells)

		// Should be "This ""cat"" is bonkers","dog"
		XCTAssertEqual(str, "\"aaa\",\"b \r\nbb\",\"ccc\"\r\n\"zzz\",\"yyy\",\"xxx\"\r\n")
	}
}
