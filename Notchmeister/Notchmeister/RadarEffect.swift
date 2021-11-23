//
//  RadarEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/22/21.
//

import AppKit

class RadarEffect: NotchEffect {
	
	let context = CIContext(options: nil)

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
		
		var bounds = parentLayer.bounds
		if Defaults.shouldFakeNotch {
			bounds.size.height = 38
		}
		
		do { // the layer that will present sublayers with a perspective transform
			radarLayer.bounds = bounds
			radarLayer.contentsScale = parentLayer.contentsScale
			radarLayer.position = CGPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.maxY)
			radarLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
			
			radarLayer.transform = CATransform3DMakeRotation(-.pi/2, 1, 0, 0)
		}

		do { // the layer that shows the radar screen
			let image = NSImage(named: "xray")!

			screenLayer.bounds = radarLayer.bounds
			screenLayer.masksToBounds = true
			screenLayer.contentsScale = radarLayer.contentsScale
			screenLayer.contentsGravity = .bottom // which is really the top
			//screenLayer.contentsGravity = .resizeAspect
			screenLayer.position = CGPoint(x: screenLayer.bounds.midX, y: screenLayer.bounds.midY)
	//		screenLayer.anchorPoint = .zero //CGPoint(x: 0.5, y: 0.5)
			screenLayer.backgroundColor = NSColor.black.cgColor
			screenLayer.cornerRadius = CGFloat.notchLowerRadius
			screenLayer.opacity = 0.5
			screenLayer.opacity = 1
			
			//var proposedRect: CGRect? = nil
			screenLayer.contents = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
		}
		
		do { // the layer that is a frame holding the screen
			frameLayer.bounds = radarLayer.bounds
			frameLayer.borderWidth = 2
			frameLayer.borderWidth = 0
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
			updateImage(at: point)
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

	private func updateImage(at point: CGPoint) {
		guard let parentLayer = parentLayer else { return }

		let scale = parentLayer.contentsScale
		
		let cursor = NSCursor.current
		let cursorSize = cursor.image.size // in points
		let hotSpot = cursor.hotSpot

		let cursorOriginPoint = CGPoint(x: (point.x), y: (point.y + cursorSize.height))

		let scaledPoint = CGPoint(x: cursorOriginPoint.x * scale, y: cursorOriginPoint.y * scale)

		debugLog("hotSpot = \(hotSpot), point = \(point), scaledPoint = \(scaledPoint)")

		//let cursorSize = cursor.image.size // in points
		//let scaledHotSpot = CGPoint(x: hotSpot.x * scale, y: hotSpot.y * scale)
		
		if let cursorBitmap = cursor.image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			if let baseBitmap = NSImage(named: "xray")?.cgImage(forProposedRect: nil, context: nil, hints: nil) {

				let baseImage = CIImage(cgImage: baseBitmap)
				let baseExtent = baseImage.extent // in pixels

				let cursorImage = CIImage(cgImage: cursorBitmap)
				let cursorExtent = cursorImage.extent
				
				// Core Image extent origin is in lower-left
				let xOffset = baseExtent.minX + scaledPoint.x
				let yOffset = baseExtent.maxY - scaledPoint.y
				
				let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
				let transformImage = cursorImage.transformed(by: transform)
				
				if let compositingFilter = CIFilter(name: "CISourceAtopCompositing") {
					compositingFilter.setDefaults()
					compositingFilter.setValue(transformImage, forKey: kCIInputImageKey)
					compositingFilter.setValue(baseImage, forKey: kCIInputBackgroundImageKey)
					
					if let filteredImage = compositingFilter.outputImage?.cropped(to: baseImage.extent) {
						if let filteredBitmap = context.createCGImage(filteredImage, from: baseImage.extent) {
							CATransaction.withActionsDisabled {
								screenLayer.contents = filteredBitmap
							}
						}
					}
				}
			}
		}
		
		/*
			 if let glowBaseImage = NSImage(named: "glowBase") {
				 let glowBaseSize = glowBaseImage.size
				 
				 // record the hot spot in normalized coordinates relative to the center of the cursor since that's where we're scaling the image from
				 let normalizedHotSpotPoint = NSPoint(x: (hotSpot.x / cursorSize.width) - 0.5, y: (hotSpot.y / cursorSize.height) - 0.5)
				 
				 //var proposedRect = CGRect(origin: .zero, size: cursorSize)
				 var proposedRect = CGRect(origin: .zero, size: glowBaseSize)
				 //if let cgImage = cursor.image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) {
				 if let cgImage = glowBaseImage.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) {
					 let ciImage = CIImage(cgImage: cgImage)
					 // NOTE: The image processing here will be more complicated, this is just a placeholder.
					 if let filter = CIFilter(name: "CIDiscBlur") {
						 let blurScale: CGFloat = 10
						 
						 // glowBaseImage = 20 x 20 pt
						 // ciImage.extent = 40 x 40 @ 0,0
						 // blurScale = 10, filteredCiImage = 100 x 100 @ -30, -30, sublayerSize = 50 x 50 pt
						 // blurScale = 5, filteredCiImage = 70 x 70 @ -15, -15, sublayerSize = 35 x 35 pt
						 // blurScale = 1, filteredCiImage = 46 x 46 @ -3, -3, sublayerSize = 23 x 23 pt

						 filter.setDefaults()
						 filter.setValue(ciImage, forKey: kCIInputImageKey)
						 filter.setValue(blurScale, forKey: kCIInputRadiusKey)
						 
						 if let filteredCiImage = filter.outputImage {
							 debugLog("filteredCiImage.extent = \(filteredCiImage.extent)")
							 if let sublayerCgImage = context.createCGImage(filteredCiImage, from: filteredCiImage.extent) {
								 let scale = sublayer.contentsScale
								 let sublayerSize = CGSize(width: CGFloat(sublayerCgImage.width) / scale, height: CGFloat(sublayerCgImage.height) / scale)
								 //debugLog("sublayerSize = \(sublayerSize)") //
								 sublayer.bounds = CGRect(origin: .zero, size: sublayerSize)
								 sublayer.anchorPoint = CGPoint(x: 0.5 + (normalizedHotSpotPoint.x / blurScale), y: 0.5 + (normalizedHotSpotPoint.y / blurScale))
								 sublayer.contents = sublayerCgImage
							 }
						 }
					 }
				 }
			 }
		 */
	}
	
}
