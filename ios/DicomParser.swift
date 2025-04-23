import Foundation

struct DicomTag {
    let group: UInt16
    let element: UInt16
    let vr: String
    let length: UInt32
    let value: Data
    var frames: [Data]? 
    
    /// Interprets little‑endian US/SS/UL values as Swift `Int`.
    var asInt: Int? {
        guard length == 2 || length == 4 else { return nil }
        return value.withUnsafeBytes {
            length == 2
            ? Int(UInt16(littleEndian: $0.load(as: UInt16.self)))
            : Int(UInt32(littleEndian: $0.load(as: UInt32.self)))
        }
    }

    /// Returns the raw value field as `Data`.
    var asData: Data? { value }
}

class DicomParser {
    private let data: Data
    private var cursor: Int = 0

    init(fileURL: URL) throws {
        self.data = try Data(contentsOf: fileURL)
        self.cursor = 0
    }

    func parse() -> [DicomTag] {
        var tags: [DicomTag] = []

        // Skip 128-byte preamble + "DICM" (4 bytes)
        cursor = 132

        while cursor + 8 <= data.count {
            guard let tag = readTag() else { 
                break 
            }
            tags.append(tag)
        }
        return tags
    }

    private func readTag() -> DicomTag? {
        guard cursor + 8 <= data.count else { 
            return nil 
        }

        let group = readUInt16()
        let element = readUInt16()
        let vr = readString(length: 2)
        var length: UInt32 = 0
        
        // Handle special cases
        if vr == "SQ" || (group == 0x7FE0 && element == 0x0010) { // Sequence or Pixel Data
            cursor += 2 // Skip reserved bytes
            length = readUInt32()
            
            if length == 0xFFFFFFFF {                
                if vr == "SQ" {
                    // Skip sequence items until sequence delimiter
                    var sequenceData = Data()
                    while cursor + 8 <= data.count {
                        let itemGroup = readUInt16()
                        let itemElement = readUInt16()
                        
                        if itemGroup == 0xFFFE {
                            let itemLength = readUInt32()
                            if itemElement == 0xE0DD { // Sequence Delimiter
                                break
                            } else if itemElement == 0xE000 { // Item
                                if itemLength != 0xFFFFFFFF {
                                    if cursor + Int(itemLength) <= data.count {
                                        let itemData = data.subdata(in: cursor..<(cursor + Int(itemLength)))
                                        sequenceData.append(itemData)
                                        cursor += Int(itemLength)
                                    }
                                }
                            }
                        } else {
                            cursor -= 4 // Move back if not a FFFE tag
                            break
                        }
                    }
                    return DicomTag(group: group, element: element, vr: vr, length: UInt32(sequenceData.count), value: sequenceData)
                } else {
                    // Handle encapsulated pixel data
                    var frames: [Data] = []
                    
                    // Skip Basic Offset Table
                    let itemGroup = readUInt16()
                    let itemElement = readUInt16()
                    if itemGroup == 0xFFFE && itemElement == 0xE000 {
                        let offsetTableLength = readUInt32()
                        cursor += Int(offsetTableLength)
                    } else {
                        cursor -= 4
                    }
                    
                    // Read each frame
                    while cursor + 8 <= data.count {
                        let frameGroup = readUInt16()
                        let frameElement = readUInt16()
                        let frameLength = readUInt32()
                        
                        if frameGroup == 0xFFFE {
                            if frameElement == 0xE000 { // Frame Item
                                if cursor + Int(frameLength) <= data.count {
                                    let frameData = data.subdata(in: cursor..<(cursor + Int(frameLength)))
                                    if let jpegStart = frameData.firstRange(of: Data([0xFF, 0xD8])) {
                                        let jpegData = frameData.subdata(in: jpegStart.startIndex..<frameData.endIndex)
                                        frames.append(jpegData)
                                    }
                                    cursor += Int(frameLength)
                                }
                            } else if frameElement == 0xE0DD { // Sequence Delimiter
                                break
                            }
                        } else {
                            cursor -= 8
                            break
                        }
                    }
                    
                    return DicomTag(group: group, element: element, vr: vr, length: length, value: Data(), frames: frames)
                }
            }
        }
        // Handle other VRs with 2-byte or 4-byte length
        else if ["OB", "OW", "UN", "UT"].contains(vr) {
            cursor += 2 // Reserved bytes
            length = readUInt32()
        } else {
            length = UInt32(readUInt16())
        }

        guard cursor + Int(length) <= data.count else {
            return nil 
        }

        let value = data.subdata(in: cursor..<(cursor + Int(length)))
        cursor += Int(length)

        return DicomTag(group: group, element: element, vr: vr, length: length, value: value)
    }

    private func readUInt16() -> UInt16 {
        let val = data.subdata(in: cursor..<(cursor + 2)).withUnsafeBytes { $0.load(as: UInt16.self) }
        cursor += 2
        return UInt16(littleEndian: val)
    }

    private func readUInt32() -> UInt32 {
        let val = data.subdata(in: cursor..<(cursor + 4)).withUnsafeBytes { $0.load(as: UInt32.self) }
        cursor += 4
        return UInt32(littleEndian: val)
    }

    private func readString(length: Int) -> String {
        let bytes = data.subdata(in: cursor..<(cursor + length))
        cursor += length
        return String(data: bytes, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
    }
}
