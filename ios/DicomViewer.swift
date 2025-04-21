@objc(DicomViewer)
class DicomViewer: NSObject {
  @objc(viewDicom:withResolver:withRejecter:)
  func viewDicom(filePath: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
    // TODO: Use native viewer or open image
    resolve("Viewing DICOM at \(filePath)")
  }
} 
