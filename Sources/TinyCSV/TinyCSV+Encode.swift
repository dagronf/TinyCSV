//
//  TinyCSV+Encode.swift
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

// CSV encoder routines

import Foundation

public extension TinyCSV.Coder {
	/// Encode CSV data to a string
	/// - Parameters:
	///   - csvdata: An array of array of strings
	///   - delimiter: The delimiter to use
	/// - Returns: a CSV-encoded string
	func encode(csvdata: [[String]], delimiter: TinyCSV.Delimiter = .comma) -> String {
		var out = ""
		for row in csvdata {
			for cell in row.enumerated() {
				if cell.offset > 0 {
					out += "\(delimiter)"
				}
				let encoded = cell.element.replacingOccurrences(of: "\"", with: "\"\"")
				out += "\"\(encoded)\""
			}
			out += "\r\n"
		}
		return out
	}
}
