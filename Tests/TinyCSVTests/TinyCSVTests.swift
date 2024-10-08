import XCTest
@testable import TinyCSV

func loadCSV(name: String, extn: String) throws -> String {
	let fileURL = Bundle.module.url(forResource: name, withExtension: extn)!
	return try String(contentsOf: fileURL)
}

final class TinyCSVDecoderTests: XCTestCase {

	func testEmpty() {
		let result1 = TinyCSV.Coder().decode(text: "")
		XCTAssertEqual(result1.records.count, 0)

		let result2 = TinyCSV.Coder().decode(text: " ")
		XCTAssertEqual(result2.records.count, 0)

		let result3 = TinyCSV.Coder().decode(text: " \n ")
		XCTAssertEqual(result3.records.count, 0)
	}

	func testSimple() {
		do {
			let text = """
3,5,6,2,1,7,8
4,5,7,3,2,8,9
"""
			let result = TinyCSV.Coder().decode(text: text)
			XCTAssertEqual(result.records.count, 2)
			XCTAssertEqual(result.records[0], ["3", "5", "6", "2", "1", "7", "8"])
			XCTAssertEqual(result.records[1], ["4", "5", "7", "3", "2", "8", "9"])
		}
	}

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

	func testComment() throws {
		let text = """
  # Here is my amazing, and \"groovy\", commented file!
  cat, dog, pig
  fish, truck, snozzle
  """

		let parser = TinyCSV.Coder()
		do {
			// Ignore the comment character
			let result = parser.decode(text: text)
			XCTAssertEqual(3, result.records.count)
			XCTAssertEqual(result.records[0], ["# Here is my amazing", "and \"groovy\"", "commented file!"])
			XCTAssertEqual(result.records[1], ["cat", "dog", "pig"])
			XCTAssertEqual(result.records[2], ["fish", "truck", "snozzle"])
		}

		do {
			// Supply a comment character
			let result = parser.decode(text: text, commentCharacter: "#")
			XCTAssertEqual(2, result.records.count)
			XCTAssertEqual(result.records[0], ["cat", "dog", "pig"])
			XCTAssertEqual(result.records[1], ["fish", "truck", "snozzle"])
		}

		do {
			let text = "% First line\n%Second line\nThird, Line"
			let result = parser.decode(text: text, commentCharacter: "%")
			XCTAssertEqual(1, result.records.count)
			XCTAssertEqual(result.records[0], ["Third", "Line"])
		}
	}

	func testNumHeaders() throws {
		let demoText = """
#Release 0.4
#Copyright (c) 2015 SomeCompany.
#
Z10,9,HFJ,,,,,,,
# Another
B12,, IZOY, AB_K9Z_DD_18, RED,, 12,,,
"""
		let parser = TinyCSV.Coder()

		do {
			let result = parser.decode(text: demoText, delimiter: .comma, commentCharacter: "#")
			XCTAssertEqual(2, result.records.count)
			XCTAssertEqual(result.records[0], ["Z10", "9", "HFJ", "", "", "", "", "", "", ""])
			XCTAssertEqual(result.records[1], ["B12", "", "IZOY", "AB_K9Z_DD_18", "RED", "", "12", "", "", ""])
		}

		do {
			// Skip the first two lines
			let result = parser.decode(text: demoText, delimiter: .comma, headerLineCount: 2)
			XCTAssertEqual(4, result.records.count)
			XCTAssertEqual(result.records[0], ["#"])
			XCTAssertEqual(result.records[1], ["Z10", "9", "HFJ", "", "", "", "", "", "", ""])
			XCTAssertEqual(result.records[2], ["# Another"])
			XCTAssertEqual(result.records[3], ["B12", "", "IZOY", "AB_K9Z_DD_18", "RED", "", "12", "", "", ""])
		}

		do {
			// First line header line, comments
			let result = parser.decode(text: demoText, delimiter: .comma, commentCharacter: "#", headerLineCount: 1)
			XCTAssertEqual(2, result.records.count)
			XCTAssertEqual(result.records[0], ["Z10", "9", "HFJ", "", "", "", "", "", "", ""])
			XCTAssertEqual(result.records[1], ["B12", "", "IZOY", "AB_K9Z_DD_18", "RED", "", "12", "", "", ""])
		}
	}

	func testHeaders2() throws {
		let text = """
Name	Size	Bytes	Class	Attributes

data	462x357	1319472	double
data1	1x152	1216	double
data2	1x152	1216	double
t	462x357	1448071	table
"""

		let result = TinyCSV.Coder().decode(text: text, delimiter: .tab, headerLineCount: 2)
		XCTAssertEqual(4, result.records.count)
		XCTAssertEqual(result.records[0], ["data", "462x357", "1319472", "double"])
		XCTAssertEqual(result.records[1], ["data1", "1x152", "1216", "double"])
		XCTAssertEqual(result.records[2], ["data2", "1x152", "1216", "double"])
		XCTAssertEqual(result.records[3], ["t", "462x357", "1448071", "table"])
	}

	func testSlightlyMoreComplex() throws {
		let text =
		"# Here is my amazing, and \"groovy\", commented file!\r" +
		"cat,#dog,pig\r\n" +
		"#Here is the next comment...\n" +
		"\"cat\n#fish\", truck, snozzle"
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text, commentCharacter: "#")

		XCTAssertEqual(2, result.records.count)
		XCTAssertEqual(3, result.records[0].count)
		XCTAssertEqual(3, result.records[1].count)

		XCTAssertEqual("cat", result.records[0][0])
		XCTAssertEqual("#dog", result.records[0][1])
		XCTAssertEqual("pig", result.records[0][2])

		XCTAssertEqual("cat\n#fish", result.records[1][0])
		XCTAssertEqual("truck", result.records[1][1])
		XCTAssertEqual("snozzle", result.records[1][2])
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
			2,-James,32
			3,,
			6

			,Tom
			"""
		let parser = TinyCSV.Coder()
		do {
			let result = parser.decode(text: text)
			XCTAssertEqual(result.delimiter, .comma)
			XCTAssertEqual(6, result.records.count)
			XCTAssertEqual(result.records[0], ["id", "name" ,"age"])
			XCTAssertEqual(result.records[1], ["1", "John" ,"23"])
			XCTAssertEqual(result.records[2], ["2", "-James" ,"32"])
			XCTAssertEqual(result.records[5], ["", "Tom"])
		}

		do {
			let result = parser.decode(text: text, delimiter: "-")
			XCTAssertEqual(result.delimiter, "-")
			XCTAssertEqual(6, result.records.count)
			XCTAssertEqual(result.records[0], ["id,name,age"])
			XCTAssertEqual(result.records[1], ["1,John,23"])
			XCTAssertEqual(result.records[2], ["2,", "James,32"])
			XCTAssertEqual(result.records[5], [",Tom"])
		}
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

	func testIMDB1000() throws {
		let text = try loadCSV(name: "imdb_top_1000", extn: "csv")
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(1001, result.records.count)
		for row in result.records {
			XCTAssertEqual(16, row.count)
		}
		
		XCTAssertEqual(result.records[49][0], "https://m.media-amazon.com/images/M/MV5BZGI5MjBmYzYtMzJhZi00NGI1LTk3MzItYjBjMzcxM2U3MDdiXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_UX67_CR0,0,67,98_AL_.jpg")
		XCTAssertEqual(result.records[289][15], "16,217,773")
		XCTAssertEqual(result.records[1000][5], "Crime, Mystery, Thriller")
	}

	func testIMDBwithOddness() throws {
		// This file uses an escaping char `\` to allow embedding of `,` in a field
		// Record 65 contains a field `Dr. Seltsam\, oder wie ich lernte\, die Bombe zu lieben (1964)` which by defaults
		// parsing as "Dr. Seltsam\", "oder wie ich lernte\", "die Bombe zu lieben (1964)"
		// Providing an escaping character for unquoted fields allows parsing these custom outputs
		let fileURL = Bundle.module.url(forResource: "imdb_line65", withExtension: "csv")!
		let text = try String(contentsOf: fileURL)
		let parser = TinyCSV.Coder()

		do {
			// By default, record 65 has two more fields due to the escaping character being ignored
			let brokenResult = parser.decode(text: text)
			XCTAssertEqual(101, brokenResult.records.count)
			XCTAssertEqual(46, brokenResult.records[65].count)
		}

		do {
			// Adding the escaping character - all the records should now have the same length
			let result = parser.decode(text: text, fieldEscapeCharacter: "\\")
			XCTAssertEqual(101, result.records.count)
			result.records.forEach { row in
				XCTAssertEqual(44, row.count)
			}
		}
	}

	func testBrokenSample1() throws {
		let text = "\"They used to work here, _____ they?\",hadn't,weren't,didn't,used not,0,0,1,0,4"
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text)
		XCTAssertEqual(1, result.records.count)
		XCTAssertEqual(10, result.records[0].count)
		XCTAssertEqual(result.records[0][0], "They used to work here, _____ they?")
	}

	func testBadness() throws {
		// See https://link.springer.com/epdf/10.1007/s10618-019-00646-y?author_access_token=siAh_b--0tDYVVGfhJfPNfe4RwlQNchNByi7wbcMAY6WctoMJ0_uYw5qYic6rj8bxLlM6h9UGccgS8iiv3t-6s6YSmNbXx0OAmMN7DSsRXTWS0D3rxIGj0AkKMufb9hTfyZk8U78niFRGsr77-WHUg==
		let fileURL = Bundle.module.url(forResource: "single-row-oddness", withExtension: "csv")!
		let text = try String(contentsOf: fileURL)
		let parser = TinyCSV.Coder()
		let result = parser.decode(text: text, fieldEscapeCharacter: "\\")
		XCTAssertEqual(1, result.records.count)
		XCTAssertEqual(5, result.records[0].count)
		XCTAssertEqual(result.records[0][3], "\nwith a number of issues\nthat shows \"double quoting\"\n\"escaping\" and multi-line cells\n")
		XCTAssertEqual(result.records[0][4], ", and has only one row!")
	}

	func testNewlineInUnquotedFields() throws {
		let text = try loadCSV(name: "testNewlineInUnquotedField", extn: "tsv")
		let result = TinyCSV.Coder().decode(text: text, delimiter: .tab, fieldEscapeCharacter: "\\")
		XCTAssertEqual(2, result.records.count)
		XCTAssertEqual(result.records[0], ["fish and\nchips", "cat\nand\ndog", "bird", "womble"])
		XCTAssertEqual(result.records[1], ["This is a test", "I \"like\" this! 🥰"])
	}

	func testDifferentLanguages() throws {
		let text = try loadCSV(name: "2747", extn: "csv")
		let result = TinyCSV.Coder().decode(text: text, delimiter: .tab)

		XCTAssertEqual(26, result.records.count)
		XCTAssertTrue(result.records[6][4].contains("伏藏"))
		XCTAssertTrue(result.records[23][4].contains("དབྱར་གནས།"))
	}

	func testProgressLoading() throws {
		do {
			let text = try loadCSV(name: "imdb_top_1000", extn: "csv")

			var count = 0
			let data = TinyCSV.Coder().decode(text: text) { percentComplete in
				count += 1
			}
			XCTAssertEqual(101, count)
			XCTAssertEqual(1001, data.records.count)
		}

		do {
			let text = try loadCSV(name: "classification", extn: "csv")

			var count = 0
			let data = TinyCSV.Coder().decode(text: text) { percentComplete in
				count += 1
			}

			XCTAssertEqual(10, data.records.count)
			XCTAssertEqual(11, count)
		}
	}
}
