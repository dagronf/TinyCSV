//
//  TinyCSV+Data+parser.swift
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

// Routines for decoding csv

internal extension TinyCSV.Data {

	func decode() -> TinyCSV.Data {
		// file = [header CRLF] record *(CRLF record) [CRLF]

		index = text.startIndex
		records = []
		field = ""

		while !isEndOfFile {
			record = []
			let state = parseRecord()
			if record.count > 0 {
				if record.count == 1 && record[0].isEmpty {
					// An empty line?
					continue
				}
				if state == .endOfFileWasSeparator {
					record.append("")
				}
				records.append(record)
			}
		}

		return self
	}

	private func parseComment() -> State {
		// Read to end of line
		while true {
			if moveToNextCharacter() == false { return .endOfFile }
			if character.isNewline {
				break
			}
		}
		if moveToNextCharacter() == false { return .endOfFile }
		return .endOfLine
	}

	private func parseRecord() -> State {
		// record = field *(COMMA field)

		// If the start of the line is a #, just skip the line entirely
		if character == "#" {
			return parseComment()
		}

		while true {
			field = ""
			let state = parseField()
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
			return parseEscapedField()
		}
		else {
			return parseNonEscapedField()
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
						if isSeparator {
							if moveToNextCharacter() == false {
								// Literally a separator at the end of the file
								return .endOfFileWasSeparator
							}
							return .endOfField
						}
						if moveToNextCharacter() == false { return .endOfFile }
					}
				}
			}
			else if character == fieldEscapeCharacter {
				// The character following the escape character should be treated as a regular character
				if moveToNextCharacter() == false { return .endOfFile }
				field.append(character)
			}
			else {
				field.append(character)
			}
		}
	}

	private func parseNonEscapedField() -> State {
		// non-escaped = *TEXTDATA
		if character == fieldEscapeCharacter {
			// The character following the escape character should be treated as a string character
			if moveToNextCharacter() == false { return .endOfFile }
		}
		else if isSeparator {
			// If the separator is the last line in the file, make sure
			// we indicate that back to the parser
			if moveToNextCharacter() == false { return .endOfFileWasSeparator }
			return .endOfField
		}

		// We need to push the first character
		field.append(character)

		while true {
			// Just continue until we hit a separator
			if moveToNextCharacter() == false { return .endOfFile }

			if character == fieldEscapeCharacter {
				// The character following the escape character should be treated as a string character
				if moveToNextCharacter() == false { return .endOfFile }
				field.append(character)
			}
			else if isSeparator {
				// If the separator is the last line in the file, make sure
				// we indicate that back to the parser
				if moveToNextCharacter() == false { return .endOfFileWasSeparator }
				return .endOfField
			}
			else if isEndOfLine {
				if moveToNextCharacter() == false { return .endOfFile }
				return .endOfLine
			}
			field.append(character)
		}
	}
}

private extension TinyCSV.Data {
	private var isEndOfFile: Bool { index == text.endIndex }
	private var isEndOfLine: Bool { text[index].isNewline }
	private var isDQuote: Bool { text[index] == "\"" }
	private var isSeparator: Bool { text[index] == delimiter }
	private var character: Character { text[index] }

	private enum State {
		case endOfField
		case endOfLine
		case endOfFile
		case endOfFileWasSeparator
	}

	private func moveToNextCharacter() -> Bool {
		index = text.index(after: index)
		return !isEndOfFile
	}

	private func moveToPreviousCharacter() -> Bool {
		index = text.index(before: index)
		return index >= text.startIndex
	}

	// Skipping over whitespace, but NOT newlines!
	private func skipOverWhitespace() -> Bool {
		if character.isNewline {
			return true
		}
		if character == "\t" && delimiter == .tab {
			return true
		}
		if character.isWhitespace == false {
			return true
		}
		while moveToNextCharacter() {
			if character.isNewline {
				return true
			}
			if character == "\t" && delimiter == .tab {
				return true
			}
			if character.isWhitespace == false {
				return true
			}
		}
		return false
	}
}
