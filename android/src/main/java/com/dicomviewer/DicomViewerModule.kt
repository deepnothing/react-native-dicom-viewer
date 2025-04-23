package com.dicomviewer

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.uimanager.ViewManager
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.common.MapBuilder

class DicomViewerManager(reactContext: ReactApplicationContext) : SimpleViewManager<DicomViewerView>() {
    override fun getName() = "DicomViewer"
    
    override fun createViewInstance(reactContext: ReactApplicationContext): DicomViewerView {
        return DicomViewerView(reactContext)
    }
    
    @ReactProp(name = "filePath")
    fun setFilePath(view: DicomViewerView, path: String) {
        view.setFilePath(path)
    }
    
    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
        return MapBuilder.builder<String, Any>()
            .put("onLoadComplete", 
                MapBuilder.of("registrationName", "onLoadComplete"))
            .build()
    }
}
