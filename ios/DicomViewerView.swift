import Foundation
import UIKit

@objc(DicomViewerView)
class DicomViewerView: UIView {
    
    private var images: [CGImage] = []
    private var currentIndex: Int = 0
    
    @objc var src: NSString = "" {
        didSet {
            print("[DicomViewerView] Received DICOM file path: \(src)")
            loadAndParseDicomFile(named: src as String)
        }
    }
    
    @objc var onSeriesEnd: RCTDirectEventBlock?
    @objc var onSeriesBegin: RCTDirectEventBlock?
    
    private func loadAndParseDicomFile(named filename: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
            print("[DicomViewerView] Could not find DICOM file named \(filename)")
            return
        }

        print("[DicomViewerView] Loading DICOM series...")

        do {
            let parser = try DicomParser(fileURL: URL(fileURLWithPath: path))
            let tags = parser.parse()

            // 1. Collect the information we need while iterating.
            var columns: Int?
            var rows: Int?
            var numberOfFrames: Int = 1
            var pixelFrames: [Data]?

            for tag in tags {
                switch (tag.group, tag.element) {
                case (0x0028, 0x0010): // Rows
                    rows = tag.asInt

                case (0x0028, 0x0011): // Columns
                    columns = tag.asInt

                case (0x0028, 0x0008): // Number of Frames
                    if let frames = tag.value.withUnsafeBytes({ String(bytes: $0, encoding: .ascii) }) {
                        numberOfFrames = Int(frames.trimmingCharacters(in: .whitespaces)) ?? 1
                        print("[DicomViewerView] Found \(numberOfFrames) frames in series")
                    }

                case (0x7FE0, 0x0010): // Pixel Data
                    pixelFrames = tag.frames
                    if let frames = tag.frames {
                        print("[DicomViewerView] Found \(frames.count) JPEG frames")
                    }

                default:
                    break
                }
            }
            
            // 2. Process frames after we have all metadata
            if let w = columns, let h = rows, let frames = pixelFrames {
                // Clear existing images
                images.removeAll()
                
                // Process each frame
                for (index, frameData) in frames.enumerated() {
                    if let cgImg = createGrayscaleImage(from: frameData, width: w, height: h) {
                        images.append(cgImg)
                    }
                }
                
                print("[DicomViewerView] Loaded \(images.count) images in series")
                
                // Show the first image
                DispatchQueue.main.async {
                    self.showImageAtIndex(0)
                }
            } else {
                print("[DicomViewerView] Missing required DICOM attributes")
            }
        } catch {
            print("[DicomViewerView] Failed to parse DICOM file: \(error)")
        }
    }

    // Simplify image creation since we're now passing individual frame data
    func createGrayscaleImage(from frameData: Data, width: Int, height: Int) -> CGImage? {
        if let dataProvider = CGDataProvider(data: frameData as CFData),
           let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil),
           let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
            return image
        }
        return nil
    }

    private func showImageAtIndex(_ index: Int) {
        guard index >= 0 && index < images.count else { return }
        
        // Replace previous image view (if any)
        self.subviews
            .filter { $0 is UIImageView }
            .forEach { $0.removeFromSuperview() }

        let imageView = UIImageView(image: UIImage(cgImage: images[index]))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(imageView)
        
        // Fire events when reaching beginning or end of series
        if index == 0 {
            onSeriesBegin?([:])
        } else if index == images.count - 1 {
            onSeriesEnd?([:])
        }
        
        currentIndex = index
    }

    // Gesture handling to scroll through frames

    private var lastTouchY: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupScrollHandling()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
        setupScrollHandling()
    }

    private func setupScrollHandling() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Store initial position
            lastTouchY = gesture.location(in: self).y
            
        case .changed:
            let currentY = gesture.location(in: self).y
            let deltaY = currentY - lastTouchY
            
            // Calculate absolute position relative to view height
            let absolutePosition = max(0, min(currentY / self.bounds.height, 1.0))
            
            // Map absolute position directly to frame index
            let targetIndex = Int(absolutePosition * Double(images.count - 1))
            
            // Show frame if index changed
            if targetIndex != currentIndex {
                showImageAtIndex(targetIndex)
            }
            
        case .ended:
            // Optional: Add momentum scrolling here if desired
            break
            
        default:
            break
        }
    }
}
