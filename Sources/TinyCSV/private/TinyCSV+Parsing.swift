//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

// Routines for decoding csv

extension TinyCSV.EventDrivenDecoder {
	@inlinable @inline(__always) func performEmitCurrentField(text: String) -> Bool {
		self.emitField?(self.currentRow, self.record.count, text) ?? true
	}

	@inlinable @inline(__always) func performEmitCurrentRecord() -> Bool {
		self.emitRecord?(self.currentRow, self.record) ?? true
	}

	func startParsing() {
		// file = [header CRLF] record *(CRLF record) [CRLF]

		defer {
			self.field = ""
			self.record = []
			self.progressCallback?(100)
		}

		// Indicate start
		self.progressCallback?(0)

		// If the text is empty, just drop out
		if self.isEndOfFile {
			return
		}

		self.currentIndex = self.text.startIndex

		self.field.reserveCapacity(1024)
		self.field.removeAll(keepingCapacity: true)

		self.currentRow = 0

		let sz = self.text.endIndex.utf16Offset(in: self.text)
		var last = 0

		// Set the current character to the first element of the string
		self.currentCharacter = self.text[self.text.startIndex]

		while !self.isEndOfFile {
			if let callback = self.progressCallback {
				let current = self.currentIndex.utf16Offset(in: self.text)
				let nv = current * 100 / sz
				if nv != last {
					callback(nv)
					last = nv
				}
			}

			self.record.removeAll(keepingCapacity: true)
			let state = self.parseRecord()
			if self.record.count > 0 {
				if self.record.count == 1 && self.record[0].isEmpty {
					// An empty line?
					continue
				}
				if state == .endOfFileWasSeparator {
					if self.performEmitCurrentField(text: "") == false {
						// Callback has told us to stop
						return
					}
					self.record.append("")
				}

				if self.performEmitCurrentRecord() == false {
					// Callback has told us to stop
					return
				}
				self.currentRow += 1
			}
		}
	}

	private func skipLine() -> State {
		// We should be right at the start of the comment line.
		// Make sure we check -- the line might be completely blank (ie. the current character is a newline)

		// Read to end of line
		while true {
			if self.currentCharacter.isNewline {
				break
			}
			if self.moveToNextCharacter() == false { return .endOfFile }
		}
		if self.moveToNextCharacter() == false { return .endOfFile }
		return .endOfLine
	}

	private func parseRecord() -> State {
		// record = field *(COMMA field)

		// If the start of the line is
		// * within the header line count, or
		// * the comment character
		// just skip the line entirely
		if self.headerLineCount > 0 || self.currentCharacter == self.commentCharacter {
			if self.headerLineCount > 0 { self.headerLineCount -= 1 }
			return self.skipLine()
		}

		while true {
			self.field.removeAll(keepingCapacity: true)
			let state = self.parseField()
			if self.performEmitCurrentField(text: self.field) == false {
				// callback has told us to stop
				return .endOfFile
			}
			self.record.append(self.field)
			if state != .endOfField {
				return state
			}
		}
	}

	private func parseField() -> State {
		//  field = (escaped / non-escaped)
		if self.skipOverWhitespace() == false {
			return .endOfFile
		}

		if self.isEndOfLine {
			// Had whitespace before the end of the line, so treat it as a blank field
			if self.moveToNextCharacter() == false { return .endOfFile }
			return .endOfLine
		}

		if self.isDQuote {
			return self.parseEscapedField()
		}
		else {
			return self.parseNonEscapedField()
		}
	}

	private func parseEscapedField() -> State {
		// escaped = DQUOTE *(TEXTDATA / COMMA / CR / LF / 2DQUOTE) DQUOTE
		while true {
			if self.moveToNextCharacter() == false { return .endOfFile }
			if isDQuote {
				if self.moveToNextCharacter() == false { return .endOfFile }
				if self.isDQuote {
					self.field.append("\"")
				}
				else {
					// If we've hit the end of an escaped string, we should attempt to locate either
					// 1. The next separator
					// 2. End of line
					while true {
						if self.isEndOfLine {
							if self.moveToNextCharacter() == false { return .endOfFile }
							return .endOfLine
						}
						if self.isDelimiter {
							if self.moveToNextCharacter() == false {
								// Literally a separator at the end of the file
								return .endOfFileWasSeparator
							}
							return .endOfField
						}

						// Usually if there is text _outside_ the quote string it's discarded
						// If `captureQuotedStringOverrunCharacters` is true, just tack the additional characters
						// onto the current field
						if self.captureQuotedStringOverrunCharacters {
							self.field.append(self.currentCharacter)
						}

						if self.moveToNextCharacter() == false { return .endOfFile }
					}
				}
			}
			else if isFieldEscape {
				// The character following the escape character should be treated as a regular character
				if self.moveToNextCharacter() == false { return .endOfFile }
				self.field.append(self.currentCharacter)
			}
			else {
				self.field.append(self.currentCharacter)
			}
		}
	}

	private func parseNonEscapedField() -> State {
		// non-escaped = *TEXTDATA
		if self.currentCharacter == fieldEscapeCharacter {
			// The character following the escape character should be treated as a string character
			if self.moveToNextCharacter() == false { return .endOfFile }
		}
		else if self.isDelimiter {
			// If the separator is the last line in the file, make sure
			// we indicate that back to the parser
			if self.moveToNextCharacter() == false { return .endOfFileWasSeparator }
			return .endOfField
		}

		// We need to push the first character
		self.field.append(currentCharacter)

		while true {
			// Just continue until we hit a separator
			if self.moveToNextCharacter() == false { return .endOfFile }

			if self.currentCharacter == self.fieldEscapeCharacter {
				// The character following the escape character should be treated as a string character
				if self.moveToNextCharacter() == false { return .endOfFile }
			}
			else if self.isDelimiter {
				// If the separator is the last line in the file, make sure
				// we indicate that back to the parser
				if self.moveToNextCharacter() == false { return .endOfFileWasSeparator }
				return .endOfField
			}
			else if isEndOfLine {
				if self.moveToNextCharacter() == false { return .endOfFile }
				return .endOfLine
			}
			self.field.append(self.currentCharacter)
		}
	}
}

extension TinyCSV.EventDrivenDecoder {
	@inlinable @inline(__always) var isEndOfFile: Bool { self.currentIndex == self.text.endIndex }
	@inlinable @inline(__always) var isEndOfLine: Bool { self.currentCharacter.isNewline }
	@inlinable @inline(__always) var isDQuote: Bool { self.currentCharacter == "\"" }
	@inlinable @inline(__always) var isDelimiter: Bool { self.currentCharacter == self.delimiter }
	@inlinable @inline(__always) var isFieldEscape: Bool { self.currentCharacter == self.fieldEscapeCharacter }
}

private extension TinyCSV.EventDrivenDecoder {
	private enum State {
		case endOfField
		case endOfLine
		case endOfFile
		case endOfFileWasSeparator
	}

	private func moveToNextCharacter() -> Bool {
		self.currentIndex = self.text.index(after: self.currentIndex)
		if self.currentIndex < self.text.endIndex {
			self.currentCharacter = self.text[self.currentIndex]
		}
		return !self.isEndOfFile
	}

	private func moveToPreviousCharacter() -> Bool {
		self.currentIndex = self.text.index(before: self.currentIndex)
		if self.currentIndex >= self.text.startIndex {
			self.currentCharacter = self.text[currentIndex]
		}
		return self.currentIndex >= self.text.startIndex
	}

	// Skipping over whitespace, but NOT newlines!
	private func skipOverWhitespace() -> Bool {
		if self.currentCharacter.isNewline {
			return true
		}
		if self.currentCharacter == "\t" && self.delimiter == .tab {
			return true
		}
		if self.currentCharacter.isWhitespace == false {
			return true
		}
		while self.moveToNextCharacter() {
			if self.currentCharacter.isNewline {
				return true
			}
			if self.currentCharacter == "\t" && self.delimiter == .tab {
				return true
			}
			if self.currentCharacter.isWhitespace == false {
				return true
			}
		}
		return false
	}
}
