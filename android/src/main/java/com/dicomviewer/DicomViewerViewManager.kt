package com.dicomviewer

import android.util.Log
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.common.MapBuilder

class DicomViewerViewManager : SimpleViewManager<DicomViewerView>() {
    
    override fun getName() = "DicomViewerView"
    
    override fun createViewInstance(reactContext: ThemedReactContext): DicomViewerView {
        Log.d("DicomViewerView", "Creating DicomViewerView instance")
        return DicomViewerView(reactContext)
    }
    
    @ReactProp(name = "src")
    fun setSrc(view: DicomViewerView, source: String) {
        Log.d("DicomViewerView", "Setting source: $source")
        view.setSource(source)
    }

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
        return MapBuilder.builder<String, Any>()
            .put("onFrameChange",
                MapBuilder.of(
                    "registrationName",
                    "onFrameChange"
                ))
            .build()
    }
} 