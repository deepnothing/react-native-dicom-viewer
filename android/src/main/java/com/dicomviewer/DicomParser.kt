package com.dicomviewer

import android.util.Log
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder

data class DicomTag(
    val group: UShort,
    val element: UShort,
    val vr: String,
    val length: UInt,
    val value: ByteArray,
    var frames: List<ByteArray>? = null
) {
    val asInt: Int?
        get() {
            if (length != 2u && length != 4u) return null
            return ByteBuffer.wrap(value)
                .order(ByteOrder.LITTLE_ENDIAN)
                .let {
                    when (length) {
                        2u -> it.short.toInt()
                        4u -> it.int
                        else -> null
                    }
                }
        }

    val asData: ByteArray?
        get() = value
}

class DicomParser(private val file: File) {
    private var data: ByteArray = file.readBytes()
    private var cursor: Int = 0

    fun parse(): List<DicomTag> {
        Log.d("DicomParser", "Starting to parse DICOM file: ${file.name}")
        val tags = mutableListOf<DicomTag>()

        // Skip 128-byte preamble + "DICM" (4 bytes)
        cursor = 132
        Log.d("DicomParser", "Skipped preamble, starting at position: $cursor")

        while (cursor + 8 <= data.size) {
            val tag = readTag()
            if (tag != null) {
                Log.d("DicomParser", "Read tag: Group=${tag.group.toString(16)}, Element=${tag.element.toString(16)}, VR=${tag.vr}, Length=${tag.length}")
                tags.add(tag)
            } else {
                Log.d("DicomParser", "Failed to read tag at position: $cursor")
                break
            }
        }

        Log.d("DicomParser", "Finished parsing, found ${tags.size} tags")
        return tags
    }

    private fun readTag(): DicomTag? {
        if (cursor + 8 > data.size) {
            Log.d("DicomParser", "Not enough data left to read tag header")
            return null
        }

        val group = readUShort()
        val element = readUShort()
        val vr = readString(2)
        var length: UInt = 0u

        Log.d("DicomParser", "Reading tag: Group=${group.toString(16)}, Element=${element.toString(16)}, VR=$vr")

        // Handle special cases
        if (vr == "SQ" || (group == 0x7FE0.toUShort() && element == 0x0010.toUShort())) { // Sequence or Pixel Data
            cursor += 2 // Skip reserved bytes
            length = readUInt()
            
            if (length == 0xFFFFFFFFu) {
                Log.d("DicomParser", "Found undefined length sequence/pixel data")
                
                if (vr == "SQ") {
                    Log.d("DicomParser", "Processing sequence items")
                    // Skip sequence items until sequence delimiter
                    val sequenceData = mutableListOf<Byte>()
                    while (cursor + 8 <= data.size) {
                        val itemGroup = readUShort()
                        val itemElement = readUShort()
                        
                        if (itemGroup == 0xFFFEu.toUShort()) {
                            val itemLength = readUInt()
                            if (itemElement == 0xE0DDu.toUShort()) { // Sequence Delimiter
                                Log.d("DicomParser", "Found sequence delimiter")
                                break
                            } else if (itemElement == 0xE000u.toUShort()) { // Item
                                Log.d("DicomParser", "Processing sequence item of length: $itemLength")
                                if (itemLength != 0xFFFFFFFFu) {
                                    if (cursor + itemLength.toInt() <= data.size) {
                                        sequenceData.addAll(data.slice(cursor until cursor + itemLength.toInt()))
                                        cursor += itemLength.toInt()
                                    }
                                }
                            }
                        } else {
                            cursor -= 4 // Move back if not a FFFE tag
                            break
                        }
                    }
                    return DicomTag(group, element, vr, sequenceData.size.toUInt(), sequenceData.toByteArray())
                } else {
                    Log.d("DicomParser", "Processing encapsulated pixel data")
                    // Handle encapsulated pixel data
                    val frames = mutableListOf<ByteArray>()
                    
                    // Skip Basic Offset Table
                    val itemGroup = readUShort()
                    val itemElement = readUShort()
                    if (itemGroup == 0xFFFEu.toUShort() && itemElement == 0xE000u.toUShort()) {
                        val offsetTableLength = readUInt()
                        Log.d("DicomParser", "Skipping offset table of length: $offsetTableLength")
                        cursor += offsetTableLength.toInt()
                    } else {
                        cursor -= 4
                    }
                    
                    // Read each frame
                    while (cursor + 8 <= data.size) {
                        val frameGroup = readUShort()
                        val frameElement = readUShort()
                        val frameLength = readUInt()
                        
                        if (frameGroup == 0xFFFEu.toUShort()) {
                            if (frameElement == 0xE000u.toUShort()) { // Frame Item
                                Log.d("DicomParser", "Reading frame of length: $frameLength")
                                if (cursor + frameLength.toInt() <= data.size) {
                                    val frameData = data.slice(cursor until cursor + frameLength.toInt()).toByteArray()
                                    // Find JPEG start marker (FF D8)
                                    val jpegStartIndex = frameData.findJpegStart()
                                    if (jpegStartIndex != -1) {
                                        Log.d("DicomParser", "Found JPEG start marker at offset: $jpegStartIndex")
                                        frames.add(frameData.slice(jpegStartIndex until frameData.size).toByteArray())
                                    }
                                    cursor += frameLength.toInt()
                                }
                            } else if (frameElement == 0xE0DDu.toUShort()) { // Sequence Delimiter
                                Log.d("DicomParser", "Found pixel data sequence delimiter")
                                break
                            }
                        } else {
                            cursor -= 8
                            break
                        }
                    }
                    
                    return DicomTag(group, element, vr, length, ByteArray(0), frames)
                }
            }
        }
        // Handle other VRs with 2-byte or 4-byte length
        else if (listOf("OB", "OW", "UN", "UT").contains(vr)) {
            cursor += 2 // Reserved bytes
            length = readUInt()
            Log.d("DicomParser", "Reading ${vr} value of length: $length")
        } else {
            length = readUShort().toUInt()
            Log.d("DicomParser", "Reading standard value of length: $length")
        }

        if (cursor + length.toInt() > data.size) {
            Log.d("DicomParser", "Not enough data left to read value of length: $length")
            return null
        }

        val value = data.slice(cursor until cursor + length.toInt()).toByteArray()
        cursor += length.toInt()

        return DicomTag(group, element, vr, length, value)
    }

    private fun readUShort(): UShort {
        val bytes = data.slice(cursor until cursor + 2).toByteArray()
        cursor += 2
        return ByteBuffer.wrap(bytes)
            .order(ByteOrder.LITTLE_ENDIAN)
            .short
            .toUShort()
    }

    private fun readUInt(): UInt {
        val bytes = data.slice(cursor until cursor + 4).toByteArray()
        cursor += 4
        return ByteBuffer.wrap(bytes)
            .order(ByteOrder.LITTLE_ENDIAN)
            .int
            .toUInt()
    }

    private fun readString(length: Int): String {
        val bytes = data.slice(cursor until cursor + length).toByteArray()
        cursor += length
        return String(bytes).trim { it <= ' ' }
    }
}

private fun ByteArray.findJpegStart(): Int {
    for (i in 0..size - 2) {
        if (this[i] == 0xFF.toByte() && this[i + 1] == 0xD8.toByte()) {
            return i
        }
    }
    return -1
} 