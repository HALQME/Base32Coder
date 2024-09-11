import Foundation

public struct Base32 {
    private static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    private static let padding = "="
    
    public static func encode(_ data: Data) -> String {
        var result = ""
        result.reserveCapacity(Int(ceil(Double(data.count) * 8 / 5)))
        
        var bits = 0
        var value = 0
        
        for byte in data {
            value = (value << 8) | Int(byte)
            bits += 8
            
            while bits >= 5 {
                bits -= 5
                let index = (value >> bits) & 0x1F
                result.append(alphabet[alphabet.index(alphabet.startIndex, offsetBy: index)])
            }
        }
        
        if bits > 0 {
            let index = (value << (5 - bits)) & 0x1F
            result.append(alphabet[alphabet.index(alphabet.startIndex, offsetBy: index)])
        }
        
        while result.count % 8 != 0 {
            result.append(padding)
        }
        
        return result
    }
    
    public static func decode(_ string: String) throws -> Data {
        let cleanedString = string.trimmingCharacters(in: .whitespaces).uppercased()
        guard cleanedString.allSatisfy({ alphabet.contains($0) || $0 == "=" }) else {
            throw Base32Error.invalidCharacter
        }
        
        var result = Data()
        var bits = 0
        var value = 0
        
        for char in cleanedString {
            if char == "=" { break }
            guard let index = alphabet.firstIndex(of: char) else {
                throw Base32Error.invalidCharacter
            }
            
            let charValue = alphabet.distance(from: alphabet.startIndex, to: index)
            value = (value << 5) | charValue
            bits += 5
            
            while bits >= 8 {
                bits -= 8
                result.append(UInt8((value >> bits) & 0xFF))
            }
        }
        
        // パディングの検証
        let paddingCount = cleanedString.filter { $0 == "=" }.count
        guard [0, 1, 3, 4, 6].contains(paddingCount) else {
            throw Base32Error.invalidPadding
        }
        
        return result
    }
    
    public enum Base32Error: Error {
        case invalidCharacter
        case invalidPadding
    }
}
