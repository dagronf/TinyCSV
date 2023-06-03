# TinyCSV

A basic Swift CSV decoder/encoder library, conforming to [RFC 4180](https://www.rfc-editor.org/rfc/rfc4180.html) as closely as possible

![Platform support](https://img.shields.io/badge/platform-ios%20%7C%20osx%20%7C%20tvos%20%7C%20watchos%20%7C%20linux-lightgrey.svg?style=flat-square)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/dagronf/TinyCSV/blob/master/LICENSE)

Designed to be a minimalist trivial reader, returning a basic array of rows of cells (strings).

TinyCSV doesn't enforce columns, header rows or 'expected' values. If the first row in your file has 10 cells and the second has only 8 cells, then that's what you'll get in the returned data. There are no column formatting rules, it is up to you to handle and massage the data after it is returned.

All processing is (currently) handled in memory, so large csv files may cause memory stress on smaller devices.

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

The encoder automatically sanitizes each cell's text, meaning you don't have to concern yourself with the csv
encoding rules.

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
