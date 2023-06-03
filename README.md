# TinyCSV

A basic Swift CSV decoder/encoder library, conforming to [RFC 4180](https://www.rfc-editor.org/rfc/rfc4180.html) as closely as possible

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

```swift
let parser = TinyCSV.Coder()

let cells = [["This \"cat\" is bonkers", "dog"], ["fish", "chips"]]
let encoded = parser.encode(csvdata: cells)
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
