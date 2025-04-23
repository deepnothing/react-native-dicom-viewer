import React

@objc(DicomViewerViewManager)
class DicomViewerViewManager: RCTViewManager {
    override func view() -> UIView! {
        return DicomViewerView()
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc override func constantsToExport() -> [AnyHashable: Any]! {
        return [:]
    }

    // Export the 'src' prop to React Native
    @objc func set_src(_ view: DicomViewerView, src: NSString) {
        view.src = src
    }
}
