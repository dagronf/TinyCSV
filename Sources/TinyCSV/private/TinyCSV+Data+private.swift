//
//  TinyCSV+Data+private.swift
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

internal extension TinyCSV {
	/// CSV Data that has been read from a file
	class Data: TinyCSVData {
		/// The records read from the file
		var records: [[String]] = []
		/// The text
		let text: String
		/// The delimiter
		let delimiter: Delimiter

		/// The character to identify as an escape character in a unquoted string
		/// For example, content like
		///
		/// ```titles01/tt0057012,tt0057012,Dr. Seltsam\, oder wie ich lernte\, die Bombe zu lieben (1964),dr seltsam oder wie ich lernte die bombe zu lieben,http://www.imdb.com/title/tt0057012/```
		var fieldEscapeCharacter: Character?

		/// The character to use to define a comment line (must be the first character in the line)
		var commentCharacter: Character?

		/// The number of lines to treat as header lines
		var headerLineCount: UInt = 0

		// Private

		var index: String.Index
		var record: [String] = []
		var field = ""

		init(
			text: String,
			delimiter: TinyCSV.Delimiter,
			fieldEscapeCharacter: Character? = nil,
			commentCharacter: Character? = nil,
			headerLineCount: UInt? = nil
		) {
			self.text = text
			self.index = text.startIndex
			self.delimiter = delimiter
			self.fieldEscapeCharacter = fieldEscapeCharacter
			self.commentCharacter = commentCharacter
			self.headerLineCount = headerLineCount ?? 0
		}
	}
}
