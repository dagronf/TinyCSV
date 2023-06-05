//
//  TinyCSV+Delimiter.swift
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

public extension TinyCSV {
	/// The delimiter type
	typealias Delimiter = Character
}

public extension TinyCSV.Delimiter {
	/// Comma delimiter
	static let comma: TinyCSV.Delimiter = ","
	/// Semicolon delimiter
	static let semicolon: TinyCSV.Delimiter = ";"
	/// Tab delimiter
	static let tab: TinyCSV.Delimiter = "\t"
	/// All the default delimiters
	static var allKnownDelimiters: [TinyCSV.Delimiter] = [
		TinyCSV.Delimiter.comma,
		TinyCSV.Delimiter.semicolon,
		TinyCSV.Delimiter.tab
	]
}

public extension TinyCSV {
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
		for delimiter in TinyCSV.Delimiter.allKnownDelimiters {
			let count = text.filter { $0 == delimiter }.count
			if count > which {
				which = count
				selected = delimiter
			}
		}
		return selected
	}
}
