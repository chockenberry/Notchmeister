//
//  RadarEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/22/21.
//

import AppKit

class RadarEffect: NotchEffect {
	
	let context = CIContext(options: nil)

	lazy var cursorImage: CIImage? = {
		let cursor = NSCursor.current

		guard let cursorBitmap = cursor.image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

		return CIImage(cgImage: cursorBitmap).applyingFilter("CIColorInvert")
	}()
	
	lazy var baseImage: CIImage? = {
		guard let parentLayer = parentLayer else { return nil }
		guard let baseBitmap = NSImage(named: "xray")?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }

		let scale = parentLayer.contentsScale
		let scaledScreenBounds = CGRect(origin: .zero, size: screenLayer.bounds.size * scale)
		let baseBounds = CGRect(origin: .zero, size: CGSize(width: baseBitmap.width, height: baseBitmap.height))

		// crop the top middle of the base image to the screen size
		let cropBounds = CGRect(origin: CGPoint(x: baseBounds.midX - scaledScreenBounds.midX, y: baseBounds.maxY - scaledScreenBounds.maxY), size: scaledScreenBounds.size)

		return CIImage(cgImage: baseBitmap).cropped(to: cropBounds)
	}()
	
	lazy var scannerImage: CIImage? = {
		guard let parentLayer = parentLayer else { return nil }

		let scale = parentLayer.contentsScale
		let scaledScreenBounds = CGRect(origin: .zero, size: screenLayer.bounds.size * scale)

		guard let gradientImage: CIImage = {
			guard let leftGradientImage: CIImage = {
				guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return nil }
				let start = scaledScreenBounds.minX
				let end = start + scaledScreenBounds.maxX
				filter.setValue(CIVector(x: start, y: 0), forKey: "inputPoint0")
				filter.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 0), forKey: "inputColor0")
				filter.setValue(CIVector(x: end, y: 0), forKey: "inputPoint1")
				filter.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 1), forKey: "inputColor1")
				let crop = CGRect(origin: CGPoint(x: start, y: 0), size: scaledScreenBounds.size)
				return filter.outputImage?.cropped(to: crop)
			}() else { return nil }

			guard let rightGradientImage: CIImage = {
				guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return nil }
				let start = scaledScreenBounds.maxX
				let end = start + scaledScreenBounds.maxX
				filter.setValue(CIVector(x: start, y: 0), forKey: "inputPoint0")
				filter.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 0), forKey: "inputColor0")
				filter.setValue(CIVector(x: end, y: 0), forKey: "inputPoint1")
				filter.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 1), forKey: "inputColor1")
				let crop = CGRect(origin: CGPoint(x: start, y: 0), size: scaledScreenBounds.size)
				return filter.outputImage?.cropped(to: crop)
			}() else { return nil }
			
			guard let filter = CIFilter(name: "CIOverlayBlendMode") else { return nil }
			filter.setDefaults()
			filter.setValue(leftGradientImage, forKey: kCIInputImageKey)
			filter.setValue(rightGradientImage, forKey: kCIInputBackgroundImageKey)
			return filter.outputImage
		}() else { return nil }
		
		let scaledCropBounds = CGRect(origin: .zero, size: CGSize(width: scaledScreenBounds.width * 2, height: scaledScreenBounds.height))
		return gradientImage.cropped(to: scaledCropBounds)
	}()
	
	var radarLayer: CATransformLayer
	var screenLayer: CALayer
	var frameLayer: CALayer

	required init(with parentLayer: CALayer) {
		self.radarLayer = CATransformLayer()
		self.screenLayer = CALayer()
		self.frameLayer = CALayer()

		super.init(with: parentLayer)

		configureSublayers()
	}
		
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		let bounds = parentLayer.bounds
		
		do { // the layer that will present sublayers with a perspective transform
			radarLayer.bounds = bounds
			radarLayer.contentsScale = parentLayer.contentsScale
			radarLayer.position = CGPoint(x: bounds.midX, y: bounds.maxY)
			radarLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
			
			radarLayer.transform = CATransform3DMakeRotation(-.pi/2, 1, 0, 0)
		}

		do { // the layer that shows the radar screen
			let image = NSImage(named: "xray")!

			screenLayer.bounds = radarLayer.bounds
			screenLayer.masksToBounds = true
			//screenLayer.masksToBounds = false // DEBUG
			screenLayer.contentsScale = radarLayer.contentsScale
			screenLayer.contentsGravity = .bottom // which is really the top
			screenLayer.contentsGravity = .resizeAspect // DEBUG
			screenLayer.position = CGPoint(x: screenLayer.bounds.midX, y: screenLayer.bounds.midY)
			screenLayer.backgroundColor = NSColor.black.cgColor
			screenLayer.cornerRadius = CGFloat.notchLowerRadius
			screenLayer.opacity = 0.5
			//screenLayer.opacity = 1 // DEBUG
			
			//var proposedRect: CGRect? = nil
			screenLayer.contents = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
		}
		
		do { // the layer that is a frame holding the screen
			frameLayer.bounds = radarLayer.bounds
			frameLayer.borderWidth = 2
			//frameLayer.borderWidth = 0 // DEBUG
			frameLayer.borderColor = NSColor(named: "radarEffect-frame")?.cgColor
			frameLayer.cornerRadius = CGFloat.notchLowerRadius
			frameLayer.masksToBounds = true
			frameLayer.contentsScale = radarLayer.contentsScale
			frameLayer.position = .zero
			frameLayer.anchorPoint = .zero
		}
		
		radarLayer.addSublayer(screenLayer)
		radarLayer.addSublayer(frameLayer)

		parentLayer.addSublayer(radarLayer)
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
	}

	var wasUnderNotch = false
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		if underNotch {
			updateScreenLayer(at: point)
		}
		else {
			//updateImage(at: point) // DEBUG
			//return // DEBUG
		}
		
		if underNotch != wasUnderNotch {
			CATransaction.begin()
			CATransaction.setCompletionBlock { [weak self] in
				if underNotch {
					//self?.startRadar()
				}
				else {
					//self?.stopRadar()
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
				//toTransform = CATransform3DMakeRotation(0, 1, 0, 0)
				toTransform = CATransform3DRotate(perspective, 0, 1, 0, 0)
			}
			else {
				//toTransform = CATransform3DMakeRotation(.pi, 1, 0, 0)
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
	}

	private func updateScreenLayer(at point: CGPoint) {
		guard let parentLayer = parentLayer else { return }

		let cursor = NSCursor.current

		guard let cursorImage = cursorImage else { return }
		guard let baseImage = baseImage else { return }
		guard let scannerImage = scannerImage else { return }

		let scale = parentLayer.contentsScale

		// NOTE: The cursor has an origin in the upper-left and is measured in points, the image has an origin in the lower-left
		// and is measured in pixels, and the point in layer has an origin in the upper-left that is measured in points.
		// The image also has a different size than the layer (which anchors it to the top center). This complicates the compositing
		// operation for the base and cursor images.
		
		// get all the coordinates we're working with into (scaled) pixel values
		let scaledCursorBounds = CGRect(origin: .zero, size: cursor.image.size * scale)
		let scaledHotSpotPoint = CGPoint(x: cursor.hotSpot.x * scale, y: cursor.hotSpot.y * scale)
		let scaledPoint = CGPoint(x: point.x * scale, y: point.y * scale)

		let baseExtent = baseImage.extent // in pixels
		let xOffset = baseExtent.minX + (scaledPoint.x - scaledHotSpotPoint.x)
		let yOffset = baseExtent.maxY - ((scaledPoint.y - scaledHotSpotPoint.y) + scaledCursorBounds.height) // flipped origin
		let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
		let transformImage = cursorImage.transformed(by: transform)

		guard let screenBaseImage: CIImage = {
			guard let filter = CIFilter(name: "CISourceAtopCompositing") else { return nil }
			filter.setDefaults()
			filter.setValue(transformImage, forKey: kCIInputImageKey)
			filter.setValue(baseImage, forKey: kCIInputBackgroundImageKey)
			return filter.outputImage?.cropped(to: baseImage.extent) // clip any extent changes caused by the cursor image
		}() else { return }

		guard let compositeImage: CIImage = {
			guard let filter = CIFilter(name: "CISourceAtopCompositing") else { return nil }
			filter.setDefaults()
			filter.setValue(screenBaseImage, forKey: kCIInputImageKey)
			filter.setValue(scannerImage, forKey: kCIInputBackgroundImageKey)
			return filter.outputImage?.cropped(to: screenBaseImage.extent)
		}() else { return }

		if let filteredBitmap = context.createCGImage(screenBaseImage, from: screenBaseImage.extent) {
//		if let filteredBitmap = context.createCGImage(scannerImage.cropped(to: screenBaseImage.extent), from: screenBaseImage.extent) {
			CATransaction.withActionsDisabled {
				screenLayer.contents = filteredBitmap
			}
		}
	}
	
}
