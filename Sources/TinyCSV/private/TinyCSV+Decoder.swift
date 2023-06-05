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

extension TinyCSV {
	/// A decoder that parses the entire text before returning
	class Decoder: EventDrivenDecoder, TinyCSVData {
		var records: [[String]] = []
		override init(
			text: String,
			delimiter: TinyCSV.Delimiter,
			fieldEscapeCharacter: Character? = nil,
			commentCharacter: Character? = nil,
			headerLineCount: UInt? = nil
		) {
			super.init(
				text: text,
				delimiter: delimiter,
				fieldEscapeCharacter: fieldEscapeCharacter,
				commentCharacter: commentCharacter,
				headerLineCount: headerLineCount
			)
			self.emitRecord = { [weak self] row, columns in
				guard let `self` = self else { return false }
				self.records.append(columns)
				return true
			}
		}

		func decode() -> TinyCSVData {
			records = []
			super.startParsing()
			return self
		}
	}
}
