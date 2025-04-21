import Foundation
import UIKit

@objc class DicomViewerView: UIView {
  private var imageViews: [UIImageView] = []
  private var dicomImages: [UIImage] = []
  private var currentIndex = 0

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.setup()
  }

  func setup() {
    self.isUserInteractionEnabled = true

    let swipe = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    self.addGestureRecognizer(swipe)
  }

  func loadDICOM(from path: String) {
    // 🧪 TODO: replace with real DICOM decoding
    // Mock: Load multiple placeholder images for now
    self.dicomImages = (1...10).compactMap { UIImage(named: "slice\($0)") }

    if let first = dicomImages.first {
      let imageView = UIImageView(image: first)
      imageView.contentMode = .scaleAspectFit
      imageView.frame = self.bounds
      imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.addSubview(imageView)
      imageViews.append(imageView)
    }
  }

  @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: self)
    if abs(translation.y) > 20 {
      let direction = translation.y > 0 ? -1 : 1
      showSlice(offset: direction)
      gesture.setTranslation(.zero, in: self)
    }
  }

  func showSlice(offset: Int) {
    let newIndex = min(max(currentIndex + offset, 0), dicomImages.count - 1)
    if newIndex != currentIndex {
      currentIndex = newIndex
      imageViews.first?.image = dicomImages[currentIndex]
    }
  }
}
