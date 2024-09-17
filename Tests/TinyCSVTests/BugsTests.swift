import XCTest
@testable import TinyCSV

final class BugsTests: XCTestCase {
	func testInvalid1() throws {

		// https://github.com/dagronf/TinyCSV/issues/3

		// let test = "\"ABC\",123,123,\"\",\"ABC\",\"\",\"\""
		let test = #""ABC",123,123,"","ABC","","""#
		Swift.print(test)

		// This produces only a single cell containing `"ABC"`.
		// This appears at first glance to be a bug, however it's a quirk of CSV - the first character
		// is a quote, which marks the cell as a quoted cell.  When the second quote is discovered, the cell
		// is complete and everything up to the next separator (or eol/eof) is discarded
		let parsed = TinyCSV.Coder().decode(text: test, delimiter: ";")
		Swift.print(parsed.records)
		XCTAssertEqual(parsed.records, [["ABC"]])

		// Solution 1
		do {
			let chunks = test.split(separator: ";")
			chunks.forEach { cellText in
				let parsed = TinyCSV.Coder().decode(text: String(cellText), delimiter: .comma)
				Swift.print(parsed.records)
			}
		}

		// Using the new `captureQuotedStringOverrunCharacters` to capture overrun characters in a quoted field
		let parsed2 = TinyCSV.Coder().decode(text: test, delimiter: ";", captureQuotedStringOverrunCharacters: true)
		XCTAssertEqual(parsed2.records, [[#"ABC,123,123,"","ABC","","""#]])
	}

	func testInvalid2() throws {

		// https://github.com/dagronf/TinyCSV/issues/3

		let test = "a,b,c,d,e,f,g;a,b,c,d,e,f,g;a,b,c,d,e,f,g;a,b,c,d,e,f,g;a,b,c,d,e,f,g"
		let parsed = TinyCSV.Coder().decode(text: test, delimiter: ";")
		Swift.print(parsed.records)

		XCTAssertEqual(parsed.records, [[
			"a,b,c,d,e,f,g", "a,b,c,d,e,f,g", "a,b,c,d,e,f,g", "a,b,c,d,e,f,g", "a,b,c,d,e,f,g" 
		]])
	}

	func testOverrunChars() throws {
		let text = #""ABC" noodle, 123, "second""#
		let parsed = TinyCSV.Coder().decode(text: text, delimiter: .comma)
		XCTAssertEqual(parsed.records, [["ABC", "123", "second"]])

		let parsed2 = TinyCSV.Coder().decode(text: text, delimiter: .comma, captureQuotedStringOverrunCharacters: true)
		XCTAssertEqual(parsed2.records, [["ABC noodle", "123", "second"]])
	}
}
