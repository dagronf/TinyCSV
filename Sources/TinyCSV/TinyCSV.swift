//
//  TinyCSV.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

public struct TinyCSV { }

public extension TinyCSV {
	struct Coder {
		public init() { }
	}
	enum Delimiter: Character, CaseIterable {
		case comma = ","
		case semi = ";"
		case tab = "\t"
	}

	/// Detect the separator for the text using a basic algorithm
	///
	/// **Method**
	///
	/// Loop through all the characters in the *first line* of the text and
	/// count the totals for each of the known delimiters.
	/// The delimiter with the highest count becomes the 'detected' delimiter.
	static func detectSeparator(text: String) -> TinyCSV.Delimiter? {
		// Get the first line in the source
		let range = text.lineRange(for: ..<text.startIndex)
		let text = text[range]

		var which = 0
		var selected: TinyCSV.Delimiter?
		for delimiter in TinyCSV.Delimiter.allCases {
			let count = text.filter { $0 == delimiter.rawValue }.count
			if count > which {
				which = count
				selected = delimiter
			}
		}
		return selected
	}
}

public extension TinyCSV.Coder {
	/// Decode CSV data
	/// - Parameters:
	///   - text: The text containing the CSV data
	///   - delimiter: The delimiter to use, or nil for auto-detect
	/// - Returns: CSV data
	func decode(text: String, delimiter: TinyCSV.Delimiter? = nil) -> TinyCSVData {
		let delimiter = delimiter ?? TinyCSV.detectSeparator(text: text) ?? .comma
		let decoder = TinyCSV.Data(text: text, delimiter: delimiter)
		return decoder.decode()
	}

	/// Encode CSV data to a string
	/// - Parameters:
	///   - csvdata: An array of array of strings
	///   - delimiter: The delimiter to use
	/// - Returns: the CSV-encoded data
	func encode(csvdata: [[String]], delimiter: TinyCSV.Delimiter = .comma) -> String {
		var out = ""
		for row in csvdata {
			for cell in row.enumerated() {
				if cell.offset > 0 {
					out += "\(delimiter.rawValue)"
				}
				let encoded = cell.element.replacingOccurrences(of: "\"", with: "\"\"")
				out += "\"\(encoded)\""
			}
			out += "\r\n"
		}
		return out
	}
}
