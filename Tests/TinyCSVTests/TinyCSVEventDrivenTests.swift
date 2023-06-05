import XCTest
@testable import TinyCSV


final class TinyCSVEventDrivenTests: XCTestCase {

	func testBasic() throws {

		do {
			let text = """
3,5,6,2,1,7,8
4,5,7,3,2,8,9
"""
			let expectedResults = [
				["3", "5", "6", "2", "1", "7", "8"],
				["4", "5", "7", "3", "2", "8", "9"]
			]

			let coder = TinyCSV.Coder()
			coder.startDecoding(
				text: text,
				emitField: { row, column, text in
					//Swift.print("\(row), \(column): \(text)")
					XCTAssertEqual(expectedResults[row][column], text)
					return true
				},
				emitRecord: { row, columns in
					//Swift.print("\(row): \(columns)")
					XCTAssertEqual(expectedResults[row], columns)
					return true
				}
			)
		}
	}

	func testLessBasic() throws {
		let text = "\"aaa\",\"b \r\nbb\",\"ccc\" \r\n\t zzz,yyy,xxx"
		let expectedResults = [
			["aaa", "b \r\nbb", "ccc"],
			["zzz", "yyy", "xxx"]
		]
		let coder = TinyCSV.Coder()

		do {
			coder.startDecoding(
				text: text,
				emitField: { row, column, text in
					//Swift.print("\(row), \(column): \(text)")
					XCTAssertEqual(expectedResults[row][column], text)
					return true
				},
				emitRecord: { row, columns in
					//Swift.print("\(row): \(columns)")
					XCTAssertEqual(expectedResults[row], columns)
					return true
				}
			)
		}

		do {
			var rows = [[String]]()
			// Stop after the first row
			coder.startDecoding(
				text: text,
				emitField: nil,
				emitRecord: { row, columns in
					//Swift.print("\(row): \(columns)")
					rows.append(columns)
					return false
				}
			)

			/// Should only have a single row because we stopped it
			XCTAssertEqual(rows.count, 1)
			XCTAssertEqual(rows[0], expectedResults[0])
		}
	}

	func testEvenLessBasic() throws {
		let text = """
  # Here is my amazing, and \"groovy\", commented file!
  cat, dog, pig
  fish, truck, snozzle
  """
		do {
			let expectedResults = [
				["# Here is my amazing", "and \"groovy\"", "commented file!"],
				["cat", "dog", "pig"],
				["fish", "truck", "snozzle"],
			]

			let coder = TinyCSV.Coder()
			coder.startDecoding(
				text: text,
				emitField: { row, column, text in
					//Swift.print("\(row), \(column): \(text)")
					XCTAssertEqual(expectedResults[row][column], text)
					return true
				},
				emitRecord: { row, columns in
					//Swift.print("\(row): \(columns)")
					XCTAssertEqual(expectedResults[row], columns)
					return true
				}
			)
		}
	}
}

