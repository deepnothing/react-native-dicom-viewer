import Foundation
import React

@objc(DicomViewerViewManager)
class DicomViewerViewManager: RCTViewManager {
  override func view() -> UIView! {
    return DicomViewerView()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  

    @objc func setPath(_ node: NSNumber, path: NSString) {
    // This will automatically execute on the proper queue
    self.bridge?.uiManager.addUIBlock { _, viewRegistry in
        if let view = viewRegistry?[node] as? DicomViewerView {
            view.loadDICOM(from: path as String)
        }
    }
}
}
