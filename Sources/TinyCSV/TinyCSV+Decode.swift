//
//  TinyCSV+Decode.swift
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

// CSV decoding routines

import Foundation

public extension TinyCSV.Coder {
	/// Start parsing CSV data
	/// - Parameters:
	///   - text: The text containing the CSV data
	///   - delimiter: The delimiter to use, or nil for auto-detect
	///   - fieldEscapeCharacter: The field escape character
	///   - commentCharacter: The comment character
	///   - headerLineCount: The number of lines at the start of the text to ignore
	///   - progressCallback: An optional callback indicating the percentage progress (0 -> 100)
	///   - emitField: Called when the parser emits a field
	///   - emitRecord: Called when the parser emits a record
	func startDecoding(
		text: String,
		delimiter: TinyCSV.Delimiter? = nil,
		fieldEscapeCharacter: Character? = nil,
		commentCharacter: Character? = nil,
		headerLineCount: UInt? = nil,
		progressCallback: ((Int) -> Void)? = nil,
		emitField: ((_ row: Int, _ column: Int, _ text: String) -> Bool)?,
		emitRecord: ((_ row: Int, _ columns: [String]) -> Bool)?
	) {
		let delimiter = delimiter ?? TinyCSV.detectSeparator(text: text) ?? .comma
		let decoder = TinyCSV.EventDrivenDecoder(
			text: text,
			delimiter: delimiter,
			fieldEscapeCharacter: fieldEscapeCharacter,
			commentCharacter: commentCharacter,
			headerLineCount: headerLineCount
		)
		decoder.emitField = emitField
		decoder.emitRecord = emitRecord
		decoder.progressCallback = progressCallback
		return decoder.startParsing()
	}

	/// Decode CSV data
	/// - Parameters:
	///   - text: The text containing the CSV data
	///   - delimiter: The delimiter to use, or nil for auto-detect
	///   - fieldEscapeCharacter: The field escape character
	///   - commentCharacter: The comment character
	///   - headerLineCount: The number of lines at the start of the text to ignore
	///   - progressCallback: An optional callback indicating the percentage progress (0 -> 100)
	/// - Returns: CSV data
	func decode(
		text: String,
		delimiter: TinyCSV.Delimiter? = nil,
		fieldEscapeCharacter: Character? = nil,
		commentCharacter: Character? = nil,
		headerLineCount: UInt? = nil,
		progressCallback: ((Int) -> Void)? = nil
	) -> TinyCSVData {
		let delimiter = delimiter ?? TinyCSV.detectSeparator(text: text) ?? .comma
		let decoder = TinyCSV.Decoder(
			text: text,
			delimiter: delimiter,
			fieldEscapeCharacter: fieldEscapeCharacter,
			commentCharacter: commentCharacter,
			headerLineCount: headerLineCount
		)
		decoder.progressCallback = progressCallback
		return decoder.decode()
	}
}
