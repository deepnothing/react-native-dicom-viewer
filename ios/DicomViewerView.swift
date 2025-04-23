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
    
    private func loadAndParseDicomFile(named filename: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
            print("[DicomViewerView] Could not find DICOM file named \(filename)")
            return
        }

        print("[DicomViewerView] Loading DICOM series with \(images.count) images")

        do {
            let parser = try DicomParser(fileURL: URL(fileURLWithPath: path))
            let tags = parser.parse()

            // 1. Collect the information we need while iterating.
            var columns      : Int?
            var rows         : Int?
            var pixelDataBlob: Data?
            var bitsAllocated: Int?
            var samplesPerPixel: Int?

            for tag in tags {
                print(String(format: "[DICOM] Tag: (%04X,%04X) VR: %@ Length: %d", tag.group, tag.element, tag.vr, tag.length))

                switch (tag.group, tag.element) {
                case (0x0028, 0x0010): // Rows
                    rows = tag.asInt
                    print("[DICOM] Found Rows: \(rows ?? -1)")

                case (0x0028, 0x0011): // Columns
                    columns = tag.asInt
                    print("[DICOM] Found Columns: \(columns ?? -1)")

                case (0x0028, 0x0100): // Bits Allocated
                    bitsAllocated = tag.asInt
                    print("[DICOM] Bits Allocated: \(bitsAllocated ?? -1)")

                case (0x0028, 0x0002): // Samples per Pixel
                    samplesPerPixel = tag.asInt
                    print("[DICOM] Samples per Pixel: \(samplesPerPixel ?? -1)")

                case (0x7FE0, 0x0010): // Pixel Data
                    pixelDataBlob = tag.asData
                    print("[DICOM] Found Pixel Data of length: \(tag.asData?.count ?? 0)")
                    if let data = tag.asData {
                        // Print first few bytes to help debug
                        let prefix = data.prefix(16).map { String(format: "%02X", $0) }.joined(separator: " ")
                        print("[DICOM] Pixel Data starts with: \(prefix)")
                    }

                case (0x0002, 0x0010): // Transfer Syntax
                    if let syntax = String(data: tag.value, encoding: .ascii) {
                        print("[DICOM] Transfer Syntax: \(syntax)")
                    }

                default:
                    break
                }
            }
            
            // 2. Create a CGImage once we have everything.
            if let w = columns,
               let h = rows,
               let data = pixelDataBlob,
               let cgImg = createGrayscaleImage(from: data, width: w, height: h) {
                
                // Add the image to our array
                images.append(cgImg)
                
                // Show the first image immediately, or update current image
                DispatchQueue.main.async {
                    self.showImageAtIndex(self.currentIndex)
                }
            } else {
                print("[DicomViewerView] Missing rows / columns / pixel data.")
            }
        } catch {
            print("[DicomViewerView] Failed to parse DICOM file: \(error)")
        }
    }

    // create images from parsed dicom data
    func createGrayscaleImage(from pixelData: Data, width: Int, height: Int) -> CGImage? {
        // For JPEG compressed data, use ImageIO to decode
        if let dataProvider = CGDataProvider(data: pixelData as CFData) {
            print("[DicomViewerView] Creating image source from data of length: \(pixelData.count)")
            if let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil) {
                print("[DicomViewerView] Created image source")
                if let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
                    print("[DicomViewerView] Successfully created CGImage")
                    return image
                } else {
                    print("[DicomViewerView] Failed to create CGImage from source")
                }
            } else {
                print("[DicomViewerView] Failed to create image source")
            }
        } else {
            print("[DicomViewerView] Failed to create data provider")
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
        
        currentIndex = index
    }

    // MARK: - Scroll testing

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
        let translation = gesture.translation(in: self)
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: self)
            
            // Determine if it was a significant swipe
            if abs(velocity.y) > 500 {  // Adjust threshold as needed
                if velocity.y > 0 {
                    // Swipe down - previous image
                    print("[DicomViewerView] Swiped down - showing previous image (currentIndex: \(currentIndex))")
                    showImageAtIndex(currentIndex - 1)
                } else {
                    // Swipe up - next image
                    print("[DicomViewerView] Swiped up - showing next image (currentIndex: \(currentIndex))")
                    showImageAtIndex(currentIndex + 1)
                }
            }
            
            // Reset gesture state
            gesture.setTranslation(.zero, in: self)
        }
    }
}
