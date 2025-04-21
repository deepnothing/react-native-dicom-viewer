@ReactModule(name = DicomViewerModule.NAME)
class DicomViewerModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
    
  override fun getName() = NAME

  @ReactMethod
  fun viewDicom(filePath: String, promise: Promise) {
    // TODO: Use dcm4che or render in an Activity
    promise.resolve("Viewing DICOM at $filePath")
  }

  companion object {
    const val NAME = "DicomViewer"
  }
}
