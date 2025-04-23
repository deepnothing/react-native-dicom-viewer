package com.dicomviewer

import android.graphics.Bitmap
import android.graphics.Color
import java.io.File
import java.nio.ByteBuffer
import org.dcm4che3.io.DicomInputStream
import org.dcm4che3.data.Attributes
import org.dcm4che3.data.Tag

class DicomParser {
    companion object {
        fun parse(filePath: String): DicomImage? {
            try {
                val file = File(filePath)
                val dis = DicomInputStream(file)
                val attrs = dis.readDataset(-1, -1)
                
                // Get image dimensions
                val width = attrs.getInt(Tag.Columns, 0)
                val height = attrs.getInt(Tag.Rows, 0)
                
                // Get pixel data
                val pixelData = attrs.getBytes(Tag.PixelData)
                if (pixelData == null || width == 0 || height == 0) {
                    return null
                }

                // Create bitmap
                val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val pixels = IntArray(width * height)
                
                // Convert pixel data to ARGB
                for (i in pixels.indices) {
                    val pixel = pixelData[i].toInt() and 0xFF
                    pixels[i] = Color.argb(255, pixel, pixel, pixel)
                }
                
                bitmap.setPixels(pixels, 0, width, 0, 0, width, height)
                
                return DicomImage(
                    bitmap = bitmap,
                    width = width,
                    height = height,
                    windowCenter = attrs.getFloat(Tag.WindowCenter, 0f),
                    windowWidth = attrs.getFloat(Tag.WindowWidth, 0f)
                )
            } catch (e: Exception) {
                e.printStackTrace()
                return null
            }
        }
    }
}

data class DicomImage(
    val bitmap: Bitmap,
    val width: Int,
    val height: Int,
    val windowCenter: Float,
    val windowWidth: Float
) 