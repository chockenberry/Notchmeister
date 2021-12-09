//
//  RadarEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/22/21.
//

import AppKit

class RadarEffect: NotchEffect {
	
	var timer: Timer?

	let XRAY_MODE = false
	
	lazy var cursorImage: CIImage? = {
		let cursor = NSCursor.current

		guard let cursorBitmap = cursor.image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
		
		if XRAY_MODE {
			return CIImage(cgImage: cursorBitmap, options: [.colorSpace: NSNull()]).applyingFilter("CIColorInvert")
		}
		else {
			return CIImage(cgImage: cursorBitmap, options: [.colorSpace: NSNull()]).applyingFilter("CIColorInvert")
		}
	}()
	
	lazy var baseImage: CIImage? = {
		debugLog("creating baseImage...")
		guard let parentLayer = parentLayer else { return nil }
		
		guard let baseBitmap = NSImage(named: "xray")?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

		let scale = parentLayer.contentsScale
		let scaledScreenBounds = CGRect(origin: .zero, size: screenLayer.bounds.size * scale)
		let baseBounds = CGRect(origin: .zero, size: CGSize(width: baseBitmap.width, height: baseBitmap.height))

		// crop the top middle of the base image to the screen size
		let cropBounds = CGRect(origin: CGPoint(x: baseBounds.midX - scaledScreenBounds.midX, y: 0), size: scaledScreenBounds.size)

		guard let croppedBitmap = baseBitmap.cropping(to: cropBounds) else { return nil }
		let croppedImage = CIImage(cgImage: croppedBitmap, options: [.colorSpace: NSNull()])
		if XRAY_MODE {
			return croppedImage.applyingFilter("CIColorControls", parameters: [kCIInputBrightnessKey: -0.25, kCIInputContrastKey: 0.75])
		}
		else {
			return croppedImage.applyingFilter("CIColorControls", parameters: [kCIInputBrightnessKey: -0.15, kCIInputContrastKey: 0.75])
		}
	}()
	
	lazy var scannerImage: CIImage? = {
		guard let parentLayer = parentLayer else { return nil }

		let scale = parentLayer.contentsScale
		let scaledScreenBounds = CGRect(origin: .zero, size: screenLayer.bounds.size * scale)

		let minColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
		let maxColor = CIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
		
		let scannerOffset: CGFloat = 10 * scale

		guard let leftGradientImage: CIImage = {
			guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return nil }
			let origin = scaledScreenBounds.minX
			let start = origin + scannerOffset
			let end = start + scaledScreenBounds.maxX
			filter.setValue(CIVector(x: start, y: 0), forKey: "inputPoint0")
			filter.setValue(minColor, forKey: "inputColor0")
			filter.setValue(CIVector(x: end, y: 0), forKey: "inputPoint1")
			filter.setValue(maxColor, forKey: "inputColor1")
			let crop = CGRect(origin: CGPoint(x: origin, y: 0), size: scaledScreenBounds.size)
			return filter.outputImage?.cropped(to: crop)
		}() else { return nil }

		guard let rightGradientImage: CIImage = {
			guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return nil }
			let origin = scaledScreenBounds.maxX
			let start = origin + scannerOffset
			let end = start + scaledScreenBounds.maxX
			filter.setValue(CIVector(x: start, y: 0), forKey: "inputPoint0")
			filter.setValue(minColor, forKey: "inputColor0")
			filter.setValue(CIVector(x: end, y: 0), forKey: "inputPoint1")
			filter.setValue(maxColor, forKey: "inputColor1")
			let crop = CGRect(origin: CGPoint(x: origin, y: 0), size: scaledScreenBounds.size)
			return filter.outputImage?.cropped(to: crop)
		}() else { return nil }
		
		guard let filter = CIFilter(name: "CIOverlayBlendMode") else { return nil }
		filter.setDefaults()
		filter.setValue(leftGradientImage, forKey: kCIInputImageKey)
		filter.setValue(rightGradientImage, forKey: kCIInputBackgroundImageKey)
	
		guard let filteredImage = filter.outputImage else { return nil }
		let scaledCropBounds = CGRect(origin: .zero, size: CGSize(width: scaledScreenBounds.width * 2, height: scaledScreenBounds.height))
		return filteredImage.cropped(to: scaledCropBounds)
	}()

	lazy var slitImage: CIImage? = {
		guard let parentLayer = parentLayer else { return nil }

		let scale = parentLayer.contentsScale
		let scaledScreenBounds = CGRect(origin: .zero, size: screenLayer.bounds.size * scale)

		let minColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
		let maxColor = CIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)

		let slitWidth: CGFloat = 20 * scale
		
		guard let leftGradientImage: CIImage = {
			guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return nil }
			let origin = scaledScreenBounds.minX
			let start = origin + (scaledScreenBounds.width - slitWidth)
			let end = start + slitWidth
			filter.setValue(CIVector(x: start, y: 0), forKey: "inputPoint0")
			filter.setValue(minColor, forKey: "inputColor0")
			filter.setValue(CIVector(x: end, y: 0), forKey: "inputPoint1")
			filter.setValue(maxColor, forKey: "inputColor1")
			let crop = CGRect(origin: CGPoint(x: origin, y: 0), size: scaledScreenBounds.size)
			return filter.outputImage?.cropped(to: crop)
		}() else { return nil }

		guard let rightGradientImage: CIImage = {
			guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return nil }
			let origin = scaledScreenBounds.maxX
			let start = origin + (scaledScreenBounds.width - slitWidth)
			let end = start + slitWidth
			filter.setValue(CIVector(x: start, y: 0), forKey: "inputPoint0")
			filter.setValue(minColor, forKey: "inputColor0")
			filter.setValue(CIVector(x: end, y: 0), forKey: "inputPoint1")
			filter.setValue(maxColor, forKey: "inputColor1")
			let crop = CGRect(origin: CGPoint(x: origin, y: 0), size: scaledScreenBounds.size)
			return filter.outputImage?.cropped(to: crop)
		}() else { return nil }
		
		guard let filter = CIFilter(name: "CIOverlayBlendMode") else { return nil }
		filter.setDefaults()
		filter.setValue(leftGradientImage, forKey: kCIInputImageKey)
		filter.setValue(rightGradientImage, forKey: kCIInputBackgroundImageKey)

		guard let filteredImage = filter.outputImage else { return nil }
		let scaledCropBounds = CGRect(origin: .zero, size: CGSize(width: scaledScreenBounds.width * 2, height: scaledScreenBounds.height))
		return filteredImage.cropped(to: scaledCropBounds)
	}()

	lazy var colorMapImage: CIImage? = {
		debugLog("creating colorMapImage...")
		guard let colorMapBitmap = NSImage(named: "colormap")?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

		return CIImage(cgImage: colorMapBitmap, options: [.colorSpace: NSNull()])
	}()

	var radarLayer: CATransformLayer
	var screenLayer: CALayer
	var frameLayer: CALayer

	var context: CIContext

	required init (with parentLayer: CALayer, in parentView: NSView) {
		self.radarLayer = CATransformLayer()
		self.frameLayer = CALayer()
		self.screenLayer = CALayer()
		self.context = CIContext(options: [.outputColorSpace: NSNull(), .workingColorSpace: NSNull()])
		
		super.init(with: parentLayer, in: parentView)

		configureSublayers()
	}
		
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		let bounds = parentLayer.bounds
		
		do { // the layer that will present sublayers with a perspective transform
			radarLayer.bounds = bounds
			//radarLayer.contentsScale = parentLayer.contentsScale
			radarLayer.position = CGPoint(x: bounds.midX, y: bounds.maxY)
			radarLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
			
			radarLayer.transform = CATransform3DMakeRotation(-.pi/2, 1, 0, 0)
		}

		do { // the layer that shows the radar screen
			//let image = NSImage(named: "xray")!

			screenLayer.bounds = radarLayer.bounds
			screenLayer.masksToBounds = true
			//screenLayer.masksToBounds = false // DEBUG
			screenLayer.contentsScale = parentLayer.contentsScale
			screenLayer.contentsGravity = .bottom // which is really the top
			//screenLayer.contentsGravity = .resizeAspect // DEBUG
			screenLayer.position = CGPoint(x: screenLayer.bounds.midX, y: screenLayer.bounds.midY)
			screenLayer.backgroundColor = NSColor.black.cgColor
			screenLayer.cornerRadius = CGFloat.notchLowerRadius
			if XRAY_MODE {
				screenLayer.opacity = 1
			}
			else {
				screenLayer.opacity = 1
			}
		}
		
		do { // the layer that is a frame holding the screen
			frameLayer.bounds = radarLayer.bounds
			frameLayer.borderWidth = 2
			//frameLayer.borderWidth = 0 // DEBUG
			frameLayer.borderColor = NSColor(named: "radarEffect-frame")?.cgColor
			frameLayer.cornerRadius = CGFloat.notchLowerRadius
			frameLayer.masksToBounds = true
			frameLayer.contentsScale = parentLayer.contentsScale
			frameLayer.position = .zero
			frameLayer.anchorPoint = .zero
		}
		
		radarLayer.addSublayer(screenLayer)
		radarLayer.addSublayer(frameLayer)

		parentLayer.addSublayer(radarLayer)
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		scannerTimeInterval = 0
	}

	var wasUnderNotch = false
	
	var lastPoint = CGPoint.zero
	var scannerTimeInterval: TimeInterval = 0
	
	private func startScanner() {
		if timer == nil {
			debugLog("starting scanner timer...")
			let sampleTimeDuration = 0.75		// time for scanner to go from one edge to another
			let sampleTimeInterval = 1.0 / 30.0 // frames per second
			let sampleTimeStep = sampleTimeInterval / sampleTimeDuration
			timer = Timer.scheduledTimer(withTimeInterval: sampleTimeInterval, repeats: true, block: { timer in
				self.updateScreenLayer(at: self.lastPoint, timeInterval: self.scannerTimeInterval)
				self.scannerTimeInterval += sampleTimeStep
				if self.scannerTimeInterval > 1 {
					self.scannerTimeInterval = 0
				}
			})
		}
	}
	
	private func stopScanner() {
		if !wasUnderNotch {
			debugLog("stopping scanner timer...")
			timer?.invalidate()
			timer = nil
		}
	}
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		if underNotch {
			lastPoint = point
		}
		
		if underNotch != wasUnderNotch {
			//debugLog("underNotch = \(underNotch), wasUnderNotch() = \(wasUnderNotch)")
			if underNotch {
				stopScanner()
				startScanner()
			}

			CATransaction.begin()
			CATransaction.setCompletionBlock { [weak self] in
				if (!underNotch) {
					self?.stopScanner()
				}
			}
			
			let fromTransform: CATransform3D
			if let transform = radarLayer.presentation()?.transform {
				fromTransform = transform
			}
			else {
				fromTransform = CATransform3DMakeRotation(-.pi/2, 1, 0, 0)
			}
			
			var perspective = CATransform3DIdentity
			perspective.m34 = -1 / 100

			let toTransform: CATransform3D
			if underNotch {
				toTransform = CATransform3DRotate(perspective, 0, 1, 0, 0)
			}
			else {
				toTransform = CATransform3DRotate(perspective, -.pi/2, 1, 0, 0)
			}
			
			radarLayer.transform = toTransform
			
			if underNotch {
				let springDownAnimation = CASpringAnimation(keyPath: "transform")
				springDownAnimation.fromValue = fromTransform
				springDownAnimation.toValue = toTransform
				springDownAnimation.duration = 2
				springDownAnimation.damping = 5
				springDownAnimation.mass = 0.25
				radarLayer.add(springDownAnimation, forKey: "transform")
			}
			else {
				let upAnimation = CABasicAnimation(keyPath: "transform")
				upAnimation.fromValue = fromTransform
				upAnimation.toValue = toTransform
				upAnimation.duration = 0.5
				upAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
				radarLayer.add(upAnimation, forKey: "transform")
			}
			
			CATransaction.commit()
			
			wasUnderNotch = underNotch
		}
	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		wasUnderNotch = false
	}

	private func updateScreenLayer(at point: CGPoint, timeInterval: TimeInterval) {
		guard let parentLayer = parentLayer else { return }

		let cursor = NSCursor.current

		guard let cursorImage = cursorImage else { return }
		guard let baseImage = baseImage else { return }
		guard let scannerImage = scannerImage else { return }
		guard let slitImage = slitImage else { return }

		let scale = parentLayer.contentsScale

		// NOTE: The cursor has an origin in the upper-left and is measured in points, the image has an origin in the lower-left
		// and is measured in pixels, and the point in layer has an origin in the upper-left that is measured in points.
		// The image also has a different size than the layer (and anchors it to the top center). This complicates the compositing
		// operation for the base and cursor images.
		
		// get all the coordinates we're working with into (scaled) pixel values
		let scaledCursorBounds = CGRect(origin: .zero, size: cursor.image.size * scale)
		let scaledHotSpotPoint = CGPoint(x: cursor.hotSpot.x * scale, y: cursor.hotSpot.y * scale)
		let scaledPoint = CGPoint(x: point.x * scale, y: point.y * scale)

		let baseExtent = baseImage.extent // in pixels
		let xOffset = baseExtent.minX + (scaledPoint.x - scaledHotSpotPoint.x)
		let yOffset = baseExtent.maxY - ((scaledPoint.y - scaledHotSpotPoint.y) + scaledCursorBounds.height) // flipped origin
		let transformedCursorImage = cursorImage.transformed(by: CGAffineTransform(translationX: xOffset, y: yOffset))

		guard let screenImage: CIImage = {
			guard let filter = CIFilter(name: "CISourceAtopCompositing") else { return nil }
			filter.setDefaults()
			filter.setValue(transformedCursorImage, forKey: kCIInputImageKey)
			filter.setValue(baseImage, forKey: kCIInputBackgroundImageKey)
			
			return filter.outputImage?.cropped(to: baseImage.extent) // clip any extent changes caused by the cursor image
		}() else { return }

		guard let screenScannerImage: CIImage = {
			guard let filter = CIFilter(name: "CIOverlayBlendMode") else { return nil }
			filter.setDefaults()
			filter.setValue(screenImage, forKey: kCIInputImageKey)
			let xOffset = timeInterval * screenImage.extent.width - screenImage.extent.width
			//let xOffset = -150.0
			filter.setValue(scannerImage.transformed(by:CGAffineTransform(translationX: xOffset, y: 0)), forKey: kCIInputBackgroundImageKey)
			
			return filter.outputImage?.cropped(to: screenImage.extent)
		}() else { return }
		
		guard let falseColorImage: CIImage = {
			guard let filter = CIFilter(name: "CIFalseColor") else { return nil }
			guard let lightColor = NSColor(named: "xrayEffect-light") else { return nil }
			guard let darkColor = NSColor(named: "xrayEffect-dark") else { return nil }
			filter.setDefaults()
			filter.setValue(screenScannerImage, forKey: kCIInputImageKey)
			filter.setValue(CIColor.init(cgColor:darkColor.cgColor), forKey: "inputColor0")
			filter.setValue(CIColor.init(cgColor:lightColor.cgColor), forKey: "inputColor1")
			
			return filter.outputImage?.cropped(to: screenImage.extent)
		}() else { return }

		guard let colorMapImage: CIImage = {
			guard let filter = CIFilter(name: "CIColorMap") else { return nil }
			guard let colorMapImage = colorMapImage else { return nil }
			filter.setDefaults()
			filter.setValue(screenScannerImage, forKey: kCIInputImageKey)
			filter.setValue(colorMapImage, forKey: kCIInputGradientImageKey)
			
			return filter.outputImage?.cropped(to: screenImage.extent)
		}() else { return }

		guard let screenScannerSlitImage: CIImage = {
			guard let filter = CIFilter(name: "CIScreenBlendMode") else { return nil }
			filter.setDefaults()
			if XRAY_MODE {
				filter.setValue(falseColorImage, forKey: kCIInputImageKey)
			}
			else {
				filter.setValue(colorMapImage, forKey: kCIInputImageKey)
			}
			let xOffset = timeInterval * screenImage.extent.width - screenImage.extent.width
			//let xOffset = -150.0
			filter.setValue(slitImage.transformed(by:CGAffineTransform(translationX: xOffset, y: 0)), forKey: kCIInputBackgroundImageKey)
			
			return filter.outputImage?.cropped(to: screenImage.extent)
		}() else { return }

		if let filteredBitmap = context.createCGImage(screenScannerSlitImage, from: screenImage.extent) {
			CATransaction.withActionsDisabled {
				screenLayer.contents = filteredBitmap
			}
		}
	}
	
}
