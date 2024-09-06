import Testing
import Foundation
@testable import Base32Coder


@Suite("Base32Tests")
struct Base32Tests {
    @Test("エンコードとデコードの一貫性")
    func testEncodeDecode() throws {
        let originalData = "こんにちは、世界！".data(using: .utf8)!
        let encoded = Base32.encode(originalData)
        let decoded = try Base32.decode(encoded)
        
        #expect(decoded == originalData)
    }
    
    @Test("無効な入力のデコード")
    func testInvalidInput() throws {
        #expect(throws: Base32.Base32Error.invalidCharacter) {
            _ = try Base32.decode("Invalid!")
        }
    }
    
    @Test("パディングの検証")
    func testPadding() throws {
        let validPadding = "MZXW6YTB"
        let invalidPadding = "MZXW6YTB=="
        
        #expect(throws: Base32.Base32Error.invalidPadding) {
            _ = try Base32.decode(invalidPadding)
        }
    }
    
    @Test("空の入力")
    func testEmptyInput() {
        let emptyData = Data()
        let encoded = Base32.encode(emptyData)
        
        #expect(encoded.isEmpty)
    }
    
    @Test("大文字小文字の無視")
    func testCaseInsensitivity() throws {
        let upperCase = "MZXW6YTB"
        let lowerCase = "mzxw6ytb"
        
        #expect(try Base32.decode(upperCase) == Base32.decode(lowerCase))
    }
}
