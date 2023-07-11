# TinyCSV

A tiny Swift CSV decoder/encoder library, conforming to [RFC 4180](https://www.rfc-editor.org/rfc/rfc4180.html) as closely as possible

![tag](https://img.shields.io/github/v/tag/dagronf/TinyCSV)
![Platform support](https://img.shields.io/badge/platform-ios%20%7C%20osx%20%7C%20tvos%20%7C%20watchos%20%7C%20macCatalyst%20%7C%20linux-lightgrey.svg?style=flat-square)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/dagronf/TinyCSV/blob/master/LICENSE) 
![Build](https://img.shields.io/github/actions/workflow/status/dagronf/TinyCSV/swift.yml)

`TinyCSV` is designed to be a minimalist csv decoder and encoder, returning a basic array of rows of cells (strings) during decoding. It attempts to be as lenient as possible when decoding, and very strict when encoding.

`TinyCSV` decoding doesn't enforce columns, header rows or 'expected' values. If the first row in your file has 10 cells and the second has only 8 cells, then that's what you'll get in the returned data. There are no column formatting rules, it is up to you to handle and massage the data after it is returned. `TinyCSV` attempts to break the input data into rows and cells following the (admittedly not well defined) CSV rules and then let you decide what you want to do with the raw once it has been parsed.

A `TinyCSV` decoder expects a Swift `String` as its input type - if you need to read csv data from a file you will have to read the file into a `String` yourself before passing it to be decoded.

All processing is (currently) handled in memory, so large csv files may cause memory stress on smaller devices. If you want to reduce your memory footprint, you might try looking into the [event driven decoding method](#event-driven-decoding-id).

## Decoding support

`TinyCSV` supports :-

* definable delimiters (eg. comma, semicolon, tab)
* basic delimiter autodetection
* Unquoted fields (eg. `cat, dog, bird`)
* Quoted fields (eg. `"cat", "dog", "bird"`)
* Mixed quoting (eg. `"cat", dog, bird`)
* Embedded quotes within quoted fields (eg. `"I like ""this""", "...but ""not"" this."`)
* Embedded quotes within unquoted fields using a field escape character (eg. `I like \"this\", ...but \"not\" this.`)
* Embedded newlines within quoted fields eg. <br/>
`"fish and`<br/>`chips, cat`<br/>`and`<br/>`dog"`
* Embedded newlines within unquoted fields using a field escape character eg. `fish and\`<br/>`chips, cat\`<br/>`and\`<br/>`dog`
* Optional comment lines
* Optional ignore header lines

## Parsing options

### Specifying a delimiter

You can specify a delimiter to use when decoding the file. 

By default, the library attempts to determine the delimiter by scanning the first row in the file. If it cannot determine a delimiter, it will default to using a comma.

```swift
// Use `tab` as a delimiter
let result = parser.decode(text: text, delimiter: .tab)

// Use `-` as the delimiter
let result = parser.decode(text: text, delimiter: "-")
```

### Skipping header lines

If your CSV file has a fixed number of lines at the start that are not part of the csv data, you can skip them by setting the header line count.

```
#Release 0.4
#Copyright (c) 2015 SomeCompany.
Z10,9,HFJ,，，，，，
B12,, IZOY, AB_K9Z_DD_18, RED,, 12,,,
```

```swift
let result = parser.decode(text: demoText, headerLineCount: 2)
```

### Line comment

You can specify the character to use to indicate that the line is to be treated as comment. If a line starts with the comment character, the line is ignored (unless it is contained within a multi-line quoted field).

For example

```
#Release 0.4
#Copyright (c) 2015 SomeCompany.
Z10,9,HFJ,，，，，，
B12,, IZOY, AB_K9Z_DD_18, RED,, 12,,,
```

```swift
// Use `#` to ignore the comment lines
let result = parser.decode(text: text, commentCharacter: "#")
```

### Field escape character

Some CSVs use an escaping character to indicate that the next character is to be taken literally, especially when dealing with files that don't quote their fields, for example :-

`…,Dr. Seltsam\, oder wie ich lernte\, die Bombe zu lieben (1964),…`

The parser allows you to optionally specify an escape charcter (in the above example, the escape char is `\`) to indicate that the embedded commas are part of the field, and is not to be treated as a delimiter.

```swift
let result = parser.decode(text: text, fieldEscapeCharacter: "\\")
```

## Examples

### Decoding

```swift
let parser = TinyCSV.Coder()

let text = /* some csv text */
let result = parser.decode(text: text)

let rowCount = result.records.count
let firstRowCellCount = result.records[0].count
let firstRowFirstCell = result.records[0][0]
let firstRowSecondCell = result.records[0][1]
```

### Encoding

The encoder automatically sanitizes each cell's text, meaning you don't have to concern yourself with the csv encoding rules.

```swift
let parser = TinyCSV.Coder()

let cells = [["This \"cat\" is bonkers", "dog"], ["fish", "chips\nsalt"]]
let encoded = parser.encode(csvdata: cells)
```

produces

```
"This ""cat"" is bonkers","dog"
"fish","chips
salt"

```

## <a name="event-driven-decoding-id"></a> Event driven decoding

`TinyCSV` internally uses an event-driven model when parsing csv content. 

The `startDecoding` method on the coder allows you to access the event driven decoding functionality if you need more fine-grained control over the decoding process, and don't want `TinyCSV` to store an entire copy of the decoded results in memory.

You can choose to receive callbacks when :- 

* The parser emits a field (including the row number, the column number and text)
* The parser emits a record (including the row number and the array of column texts)

These callback functions return a boolean value. Return `true` to continue parsing, `false` to stop.

### Example

```swift
let coder = TinyCSV.Coder()
coder.startDecoding(
   text: <some text>,
   emitField: { row, column, text in
      Swift.print("\(row), \(column): \(text)")
      return true
   },
   emitRecord: { row, columns in
      Swift.print("\(row): \(columns)")
      return true
   }
)
```

## License

```
MIT License

Copyright (c) 2023 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
