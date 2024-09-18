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

internal extension TinyCSV.EventDrivenDecoder {

	@inlinable @inline(__always) func performEmitCurrentField(text: String) -> Bool {
		self.emitField?(currentRow, record.count, text) ?? true
	}

	@inlinable @inline(__always) func performEmitCurrentRecord() -> Bool {
		self.emitRecord?(currentRow, record) ?? true
	}

	func startParsing() {
		// file = [header CRLF] record *(CRLF record) [CRLF]

		defer {
			field = ""
			record = []
			progressCallback?(100)
		}

		// Indicate start
		progressCallback?(0)

		// If the text is empty, just drop out
		if isEndOfFile {
			return
		}

		currentIndex = text.startIndex

		field.reserveCapacity(1024)
		field.removeAll(keepingCapacity: true)

		currentRow = 0

		let sz = text.endIndex.utf16Offset(in: text)
		var last = 0

		if isEndOfFile {
			// Nothing to do!
			return
		}

		// Set the current character to the first element of the string
		currentCharacter = text[text.startIndex]

		while !isEndOfFile {
			if let callback = progressCallback {
				let current = currentIndex.utf16Offset(in: text)
				let nv = current * 100 / sz
				if nv != last {
					callback(nv)
					last = nv
				}
			}

			record.removeAll(keepingCapacity: true)
			let state = self.parseRecord()
			if record.count > 0 {
				if record.count == 1 && record[0].isEmpty {
					// An empty line?
					continue
				}
				if state == .endOfFileWasSeparator {
					if self.performEmitCurrentField(text: "") == false {
						// Callback has told us to stop
						return
					}
					record.append("")
				}

				if self.performEmitCurrentRecord() == false {
					// Callback has told us to stop
					return
				}
				currentRow += 1
			}
		}
	}

	private func skipLine() -> State {
		// We should be right at the start of the comment line.
		// Make sure we check -- the line might be completely blank (ie. the current character is a newline)

		// Read to end of line
		while true {
			if currentCharacter.isNewline {
				break
			}
			if moveToNextCharacter() == false { return .endOfFile }
		}
		if moveToNextCharacter() == false { return .endOfFile }
		return .endOfLine
	}

	private func parseRecord() -> State {
		// record = field *(COMMA field)

		// If the start of the line is
		// * within the header line count, or
		// * the comment character
		// just skip the line entirely
		if headerLineCount > 0 || currentCharacter == commentCharacter {
			if headerLineCount > 0 { headerLineCount -= 1 }
			return self.skipLine()
		}

		while true {
			field.removeAll(keepingCapacity: true)
			let state = self.parseField()
			if self.performEmitCurrentField(text: field) == false {
				// callback has told us to stop
				return .endOfFile
			}
			record.append(field)
			if state != .endOfField {
				return state
			}
		}
	}

	private func parseField() -> State {
		//  field = (escaped / non-escaped)
		if skipOverWhitespace() == false {
			return .endOfFile
		}

		if isEndOfLine {
			// Had whitespace before the end of the line, so treat it as a blank field
			if moveToNextCharacter() == false { return .endOfFile }
			return .endOfLine
		}

		if isDQuote {
			return self.parseEscapedField()
		}
		else {
			return self.parseNonEscapedField()
		}
	}

	private func parseEscapedField() -> State {
		// escaped = DQUOTE *(TEXTDATA / COMMA / CR / LF / 2DQUOTE) DQUOTE
		while true {
			if moveToNextCharacter() == false { return .endOfFile }
			if isDQuote {
				if moveToNextCharacter() == false { return .endOfFile }
				if isDQuote {
					field.append("\"")
				}
				else {
					// If we've hit the end of an escaped string, we should attempt to locate either
					// 1. The next separator
					// 2. End of line
					while true {
						if isEndOfLine {
							if moveToNextCharacter() == false { return .endOfFile }
							return .endOfLine
						}
						if isDelimiter {
							if moveToNextCharacter() == false {
								// Literally a separator at the end of the file
								return .endOfFileWasSeparator
							}
							return .endOfField
						}

						// Usually if there is text _outside_ the quote string it's discarded
						// If `captureQuotedStringOverrunCharacters` is true, just tack the additional characters
						// onto the current field
						if captureQuotedStringOverrunCharacters {
							field.append(currentCharacter)
						}

						if moveToNextCharacter() == false { return .endOfFile }
					}
				}
			}
			else if isFieldEscape {
				// The character following the escape character should be treated as a regular character
				if moveToNextCharacter() == false { return .endOfFile }
				field.append(currentCharacter)
			}
			else {
				field.append(currentCharacter)
			}
		}
	}

	private func parseNonEscapedField() -> State {
		// non-escaped = *TEXTDATA
		if currentCharacter == fieldEscapeCharacter {
			// The character following the escape character should be treated as a string character
			if moveToNextCharacter() == false { return .endOfFile }
		}
		else if isDelimiter {
			// If the separator is the last line in the file, make sure
			// we indicate that back to the parser
			if moveToNextCharacter() == false { return .endOfFileWasSeparator }
			return .endOfField
		}

		// We need to push the first character
		field.append(currentCharacter)

		while true {
			// Just continue until we hit a separator
			if moveToNextCharacter() == false { return .endOfFile }

			if currentCharacter == fieldEscapeCharacter {
				// The character following the escape character should be treated as a string character
				if moveToNextCharacter() == false { return .endOfFile }
			}
			else if isDelimiter {
				// If the separator is the last line in the file, make sure
				// we indicate that back to the parser
				if moveToNextCharacter() == false { return .endOfFileWasSeparator }
				return .endOfField
			}
			else if isEndOfLine {
				if moveToNextCharacter() == false { return .endOfFile }
				return .endOfLine
			}
			field.append(currentCharacter)
		}
	}
}

private extension TinyCSV.EventDrivenDecoder {
	private var isEndOfFile: Bool { currentIndex == text.endIndex }
	private var isEndOfLine: Bool { currentCharacter.isNewline }
	private var isDQuote: Bool { currentCharacter == "\"" }
	private var isDelimiter: Bool { currentCharacter == delimiter }
	private var isFieldEscape: Bool { currentCharacter == fieldEscapeCharacter }

	private enum State {
		case endOfField
		case endOfLine
		case endOfFile
		case endOfFileWasSeparator
	}

	private func moveToNextCharacter() -> Bool {
		currentIndex = text.index(after: currentIndex)
		if currentIndex < text.endIndex {
			currentCharacter = text[currentIndex]
		}
		return !self.isEndOfFile
	}

	private func moveToPreviousCharacter() -> Bool {
		currentIndex = text.index(before: currentIndex)
		if currentIndex >= text.startIndex {
			currentCharacter = text[currentIndex]
		}
		return currentIndex >= text.startIndex
	}

	// Skipping over whitespace, but NOT newlines!
	private func skipOverWhitespace() -> Bool {
		if currentCharacter.isNewline {
			return true
		}
		if currentCharacter == "\t" && delimiter == .tab {
			return true
		}
		if currentCharacter.isWhitespace == false {
			return true
		}
		while self.moveToNextCharacter() {
			if currentCharacter.isNewline {
				return true
			}
			if currentCharacter == "\t" && delimiter == .tab {
				return true
			}
			if currentCharacter.isWhitespace == false {
				return true
			}
		}
		return false
	}
}
