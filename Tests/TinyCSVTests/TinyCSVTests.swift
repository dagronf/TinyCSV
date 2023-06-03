import XCTest
@testable import TinyCSV

final class TinyCSVTests: XCTestCase {
	func testBasic() {
		let text = "cat, dog, fish"
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(result.records.count, 1)
		XCTAssertEqual(result.records[0].count, 3)
		XCTAssertEqual(result.records[0][0], "cat")
		XCTAssertEqual(result.records[0][1], "dog")
		XCTAssertEqual(result.records[0][2], "fish")
	}

	func testBasic2() {
		let text = "cat, dog, fish\nblah1, blah2  ,blah3"
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(result.records.count, 2)
		XCTAssertEqual(result.records[0].count, 3)
		XCTAssertEqual(result.records[0][0], "cat")
		XCTAssertEqual(result.records[0][1], "dog")
		XCTAssertEqual(result.records[0][2], "fish")
		XCTAssertEqual(result.records[1].count, 3)
		XCTAssertEqual(result.records[1][0], "blah1")
		XCTAssertEqual(result.records[1][1], "blah2  ")
		XCTAssertEqual(result.records[1][2], "blah3")
	}

	func testBasic3() {
		let text = #"cat, "dog", fi"sh"#
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(result.records.count, 1)
		XCTAssertEqual(result.records[0].count, 3)
		XCTAssertEqual(result.records[0][0], "cat")
		XCTAssertEqual(result.records[0][1], "dog")
		XCTAssertEqual(result.records[0][2], #"fi"sh"#)

		do {
			let text = #"cat, "do""g", fish   "#
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 1)
			XCTAssertEqual(result.records[0].count, 3)
			XCTAssertEqual(result.records[0][0], "cat")
			XCTAssertEqual(result.records[0][1], "do\"g")
			XCTAssertEqual(result.records[0][2], "fish   ")
		}
	}

	func testBasicQuoted() {
		do {
			let text = #"cat, """dog""", fish"#
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 1)
			XCTAssertEqual(result.records[0].count, 3)
			XCTAssertEqual(result.records[0][0], "cat")
			XCTAssertEqual(result.records[0][1], "\"dog\"")
			XCTAssertEqual(result.records[0][2], "fish")
		}

		do {
			let text = #"cat, "tobble ""dog"" wobble", fish"#
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 1)
			XCTAssertEqual(result.records[0].count, 3)
			XCTAssertEqual(result.records[0][0], "cat")
			XCTAssertEqual(result.records[0][1], "tobble \"dog\" wobble")
			XCTAssertEqual(result.records[0][2], "fish")
		}
	}

	func testStrangeQuoted() throws {
		do {
			let text = "\"aaa\",\"b \r\nbb\",\"ccc\" \r\n\t zzz,yyy,xxx"
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 2)
			XCTAssertEqual(result.records[0].count, 3)
			XCTAssertEqual(result.records[0][0], "aaa")
			XCTAssertEqual(result.records[0][1], "b \r\nbb")
			XCTAssertEqual(result.records[0][2], "ccc")
			XCTAssertEqual(result.records[1].count, 3)
			XCTAssertEqual(result.records[1][0], "zzz")
			XCTAssertEqual(result.records[1][1], "yyy")
			XCTAssertEqual(result.records[1][2], "xxx")
		}
	}

	func testSlightlyMoreComplex() throws {
		let text =
		"# Here is my amazing, and \"groovy\", commented file!\r" +
		"cat,#dog,pig\r\n" +
		"#Here is the next comment...\n" +
		"\"cat\n#fish\", truck, snozzle"
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)

		XCTAssertEqual(2, result.records.count)
		XCTAssertEqual(3, result.records[0].count)
		XCTAssertEqual(3, result.records[1].count)

		XCTAssertEqual("cat", result.records[0][0]);
		XCTAssertEqual("#dog", result.records[0][1]);
		XCTAssertEqual("pig", result.records[0][2]);

		XCTAssertEqual("cat\n#fish", result.records[1][0]);
		XCTAssertEqual("truck", result.records[1][1]);
		XCTAssertEqual("snozzle", result.records[1][2]);
	}

	func testMoreQuotedFields() throws {
		let text = "id,\"name, person\",age\n\"5\",\"Smith, John\",67\n8,Joe Bloggs,\"8\""
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(result.records.count, 3)
		XCTAssertEqual(result.records[0].count, 3)
		XCTAssertEqual(result.records[0], ["id", "name, person", "age"])
		XCTAssertEqual(result.records[1], ["5", "Smith, John", "67"])
		XCTAssertEqual(result.records[2], ["8", "Joe Bloggs", "8"])
	}

	func testMoreQuotedFields2() throws {
		let fileURL = Bundle.module.url(forResource: "wonderland", withExtension: "csv")!
		let text = try String(contentsOf: fileURL)
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(4, result.records.count)
		XCTAssertEqual(2, result.records[1].count)
		XCTAssertEqual(result.records[1][0], "White Rabbit")
		XCTAssertEqual(result.records[1][1], "\"Where shall I begin, please your Majesty?\" he asked.")
		XCTAssertEqual(result.records[2][0], "King")
		XCTAssertEqual(result.records[2][1], "\"Begin at the beginning,\" the King said gravely, \"and go on till you come to the end: then stop.\"")
		XCTAssertEqual(result.records[3][0], "March Hare")
		XCTAssertEqual(result.records[3][1], "\"Do you mean that you think you can find out the answer to it?\" said the March Hare.")
	}

	func testSomeBlankFields() throws {
		do {
			let text = ",Blankman,,SomeTown, SD, 00298"
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 1)
			XCTAssertEqual(result.records[0].count, 6)
		}
	}

	func testSeparatorAtTheEndOfAFile() throws {
		do {
			let text = "cat, "
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 1)
			XCTAssertEqual(result.records[0].count, 2)
		}
		do {
			let text = "cat,"
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 1)
			XCTAssertEqual(result.records[0].count, 2)
		}
	}

	func testSeparatorAtEndOfLine() throws {
		let text = "cat,\ndog, noodle"
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(result.records.count, 2)
		XCTAssertEqual(result.records[0].count, 2)
		XCTAssertEqual("cat", result.records[0][0]);
		XCTAssertEqual("", result.records[0][1]);
		XCTAssertEqual(result.records[1].count, 2)
		XCTAssertEqual("dog", result.records[1][0]);
		XCTAssertEqual("noodle", result.records[1][1]);
	}

	func testWeirdness() throws {
		let text = """
 3,00:01:44:16,00:01:47:06,"мениджър на ресторант ""Ръсти Скапър"".",,,,
 11,00:02:11:19,00:02:15:08,"Най-вече защото бях
 директор на филиала",,,,
 """
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(result.records.count, 2)
		XCTAssertEqual(result.records[0].count, 8)
		XCTAssertEqual(result.records[1].count, 8)

	}

	func testSeparatorAtTheEndOfALine() throws {
		do {
			let text = "cat,\ndog, noodle"
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.records.count, 2)
			XCTAssertEqual(result.records[0].count, 2)
		}
	}

	func testBigger() throws {
		let fileURL = Bundle.module.url(forResource: "orig", withExtension: "csv")!
		let text = try String(contentsOf: fileURL)

		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)

		XCTAssertEqual(8, result.records.count)
		XCTAssertEqual("John \n\"Da Man\" 大夨天 🤪 太夫", result.records[0][0]);

		XCTAssertEqual(6, result.records[7].count)
		XCTAssertEqual("09119", result.records[7][5])
	}

	func testOddEncodingFile() throws {
		let fileURL = Bundle.module.url(forResource: "stby", withExtension: "csv")!
		let text = try String(contentsOf: fileURL)
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(8, result.records.count)
	}

	func testClassificationFile() throws {
		let fileURL = Bundle.module.url(forResource: "classification", withExtension: "csv")!
		let text = try String(contentsOf: fileURL)
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(10, result.records.count)
	}

	func testSemiSeparatorWithBadStrings() throws {
		let text = """
 Number;Start time in milliseconds;End time in milliseconds;"Text"
 1;91216;93093;"РегалВю ТЕЛЕМАРКЕТИНГ
 АНДЕРСЪН - МЕНИДЖЪР"
 2;102727;104562;"Тук пише, че 5 години сте бил"
 3;104646;107232;"мениджър на ресторант "Ръсти Скапър"."
 4;108817;114322;"Между 2014 и 2016 година сте бил
 касиер в банката на Оукланд?"
 5;115699;117409;"Служител на месеца."
 """

		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(6, result.records.count)
		XCTAssertEqual("1", result.records[1][0])
		XCTAssertEqual("91216", result.records[1][1])
		XCTAssertEqual("93093", result.records[1][2])
		XCTAssertEqual("РегалВю ТЕЛЕМАРКЕТИНГ\nАНДЕРСЪН - МЕНИДЖЪР", result.records[1][3])

		// This row is malformed (single quotes within quotes). Not a great deal we can do to recover from this
		// other than to just skip any text up to the next separator or eol
		XCTAssertEqual("3", result.records[3][0])
		XCTAssertEqual("104646", result.records[3][1])
		XCTAssertEqual("107232", result.records[3][2])
		XCTAssertEqual("мениджър на ресторант ", result.records[3][3])
	}

	func testTabSeparator() throws {
		do {
			let text = "cat\tdog\tfish\nbear\twomble\twhale"
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.delimiter, .tab)
			XCTAssertEqual(2, result.records.count)
			XCTAssertEqual("cat", result.records[0][0])
			XCTAssertEqual("dog", result.records[0][1])
			XCTAssertEqual("fish", result.records[0][2])
			XCTAssertEqual("bear", result.records[1][0])
			XCTAssertEqual("womble", result.records[1][1])
			XCTAssertEqual("whale", result.records[1][2])
		}

		do {
			let text = "cat\t\tdog\t\"fish\tand\tchips\"\tnoodle"
			let parser = TinyCSV.Coder()
			let result = parser.decode(text: text)
			XCTAssertEqual(result.delimiter, .tab)
			XCTAssertEqual(1, result.records.count)
			XCTAssertEqual(5, result.records[0].count)
			XCTAssertEqual("cat", result.records[0][0])
			XCTAssertEqual("", result.records[0][1])
			XCTAssertEqual("dog", result.records[0][2])
			XCTAssertEqual("fish\tand\tchips", result.records[0][3])
			XCTAssertEqual("noodle", result.records[0][4])
		}
	}

	func testEmptyFields() throws {
		let text = """
 id,name,age
 1,John,23
 2,James,32
 3,,
 6

 ,Tom
 """
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(result.delimiter, .comma)
		XCTAssertEqual(6, result.records.count)
	}

	func testSampleOrganizations1000() throws {
		let fileURL = Bundle.module.url(forResource: "organizations-1000", withExtension: "csv")!
		let text = try String(contentsOf: fileURL)
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(1001, result.records.count)
		XCTAssertEqual(9, result.records[17].count)
		XCTAssertEqual("17", result.records[17][0])
		XCTAssertEqual("Morales, Hinton and Gibbs", result.records[17][2])
		XCTAssertEqual("Museums / Institutions", result.records[17][7])
	}
}

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
