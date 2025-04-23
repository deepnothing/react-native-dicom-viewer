package com.dicomviewer

import android.content.Context
import android.widget.ImageView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter

class DicomViewerView(context: Context) : ImageView(context) {
    private var filePath: String? = null
    
    fun setFilePath(path: String) {
        filePath = path
        loadDicomImage()
    }
    
    private fun loadDicomImage() {
        filePath?.let { path ->
            val dicomImage = DicomParser.parse(path)
            dicomImage?.let { image ->
                setImageBitmap(image.bitmap)
                
                // Notify React Native that the image has loaded
                val event = Arguments.createMap().apply {
                    putBoolean("success", true)
                    putInt("width", image.width)
                    putInt("height", image.height)
                }
                
                (context as ReactContext)
                    .getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onLoadComplete", event)
            } ?: run {
                // Notify React Native that the image failed to load
                val event = Arguments.createMap().apply {
                    putBoolean("success", false)
                }
                
                (context as ReactContext)
                    .getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onLoadComplete", event)
            }
        }
    }
} 