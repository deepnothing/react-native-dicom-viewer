package com.dicomviewer

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.Log
import android.view.GestureDetector
import android.view.MotionEvent
import android.widget.FrameLayout
import android.widget.ImageView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import java.io.File
import java.io.FileOutputStream

class DicomViewerView(context: Context) : FrameLayout(context) {
    
    private var images: MutableList<android.graphics.Bitmap> = mutableListOf()
    private var currentIndex: Int = 0
    private var imageView: ImageView? = null
    private var filePath: String = ""
    
    init {
        // Set up the initial view
        setBackgroundColor(Color.BLACK)
        setupImageView()
        setupGestureDetection()
    }

    private fun setupImageView() {
        imageView = ImageView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )
            scaleType = ImageView.ScaleType.FIT_CENTER
        }
        addView(imageView)
    }

    private fun setupGestureDetection() {
        val gestureDetector = GestureDetector(context, object : GestureDetector.SimpleOnGestureListener() {
            override fun onScroll(
                e1: MotionEvent?,
                e2: MotionEvent,
                distanceX: Float,
                distanceY: Float
            ): Boolean {
                e1?.let {
                    val absolutePosition = (e2.y / height).coerceIn(0f, 1f)
                    val targetIndex = (absolutePosition * (images.size - 1)).toInt()
                    
                    if (targetIndex != currentIndex) {
                        showImageAtIndex(targetIndex)
                    }
                }
                return true
            }
        })

        setOnTouchListener { _, event ->
            gestureDetector.onTouchEvent(event)
            true
        }
    }

    fun setSource(path: String) {
        Log.d("DicomViewerView", "Setting source path: $path")
        filePath = path
        loadAndParseDicomFile(path)
    }

    private fun loadAndParseDicomFile(path: String) {
        try {
            Log.d("DicomViewerView", "Starting to load DICOM file: $path")
            
            // Try to load from assets first
            val assetManager = context.assets
            val inputStream = try {
                assetManager.open(path)
            } catch (e: Exception) {
                Log.d("DicomViewerView", "File not found in assets, trying absolute path")
                null
            }

            val file = if (inputStream != null) {
                // Create a temporary file from the asset
                val tempFile = File.createTempFile("dicom", null, context.cacheDir)
                FileOutputStream(tempFile).use { output ->
                    inputStream.use { input ->
                        input.copyTo(output)
                    }
                }
                tempFile
            } else {
                // Try as absolute path
                File(path)
            }

            if (!file.exists()) {
                Log.e("DicomViewerView", "File does not exist: $path")
                return
            }

            val parser = DicomParser(file)
            val tags = parser.parse()
                        
            // Find pixel data tag (7FE0,0010)
            val pixelDataTag = tags.find { 
                it.group == 0x7FE0.toUShort() && it.element == 0x0010.toUShort() 
            }
            
            if (pixelDataTag?.frames != null) {
                Log.d("DicomViewerView", "Found ${pixelDataTag.frames!!.size} frames in pixel data")
                images.clear()
                
                pixelDataTag.frames!!.forEach { frameData ->
                    try {
                        val bitmap = BitmapFactory.decodeByteArray(frameData, 0, frameData.size)
                        if (bitmap != null) {
                            images.add(bitmap)
                        } else {
                            Log.e("DicomViewerView", "Failed to decode frame bitmap")
                        }
                    } catch (e: Exception) {
                        Log.e("DicomViewerView", "Error decoding frame: ${e.message}")
                    }
                }
                
                if (images.isNotEmpty()) {
                    Log.d("DicomViewerView", "Successfully loaded ${images.size} frames")
                    showImageAtIndex(0)
                } else {
                    Log.e("DicomViewerView", "No frames were successfully decoded")
                }
            } else {
                Log.e("DicomViewerView", "No frames found in pixel data")
            }
            
        } catch (e: Exception) {
            Log.e("DicomViewerView", "Error parsing DICOM file: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun showImageAtIndex(index: Int) {
        if (index < 0 || index >= images.size) return

        imageView?.setImageBitmap(images[index])
        currentIndex = index
        
        // Emit frame change event
        val event = Arguments.createMap().apply {
            putInt("index", index)
            putInt("total", images.size)
        }
        
        (context as ReactContext)
            .getJSModule(RCTEventEmitter::class.java)
            .receiveEvent(id, "onFrameChange", event)
    }
} 