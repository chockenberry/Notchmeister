//
//  GlowEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/6/21.
//

import AppKit

class GlowEffect: NotchEffect {
	
	//let context = CIContext(options: nil)

	var glowLayer: CAGradientLayer
	
	var edgeLayer: CAShapeLayer
	var maskLayer: CAGradientLayer

	let glowRadius = 30.0
	let offset = 0
	
	required init(with parentLayer: CALayer) {
		self.glowLayer = CAGradientLayer()
		self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size)
		self.maskLayer = CAGradientLayer()

		super.init(with: parentLayer)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		let dimension = glowRadius * 2
		glowLayer.bounds = CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension))
		glowLayer.masksToBounds = false
		if Defaults.shouldDebugDrawing {
			glowLayer.backgroundColor = NSColor.systemBlue.cgColor
		}
		else {
			glowLayer.backgroundColor = NSColor.clear.cgColor
		}
		glowLayer.contentsScale = parentLayer.contentsScale
		glowLayer.position = .zero
		glowLayer.opacity = 0
		
		let startColor = NSColor.white
		let endColor = NSColor(calibratedWhite: 1.0, alpha: 0.0)
		
		glowLayer.type = .radial
		glowLayer.colors = [startColor.cgColor, startColor.cgColor, endColor.cgColor]
		glowLayer.locations = [0,0.25,1]
		glowLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
		glowLayer.endPoint = CGPoint(x: 1,y: 1)

		parentLayer.addSublayer(glowLayer)
		
		// TODO: Should notchOutlineLayer work in notch coordinates (origin in upper-left)?
		edgeLayer.isGeometryFlipped = parentLayer.isGeometryFlipped
		edgeLayer.anchorPoint = .zero
		edgeLayer.fillColor = NSColor.clear.cgColor
		edgeLayer.strokeColor = NSColor.white.cgColor
		edgeLayer.lineWidth = 2.0
		edgeLayer.opacity = 0

		maskLayer.bounds = CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension))
		//maskLayer.isGeometryFlipped = parentLayer.isGeometryFlipped
		maskLayer.type = .radial
		maskLayer.colors = [startColor.cgColor, startColor.cgColor, endColor.cgColor]
		maskLayer.locations = [0,0.75,1]
		maskLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
		maskLayer.endPoint = CGPoint(x: 1,y: 1)
		maskLayer.position = .zero
		
		edgeLayer.mask = maskLayer
		
		parentLayer.addSublayer(edgeLayer)
	}

	override func start() {
		
	}
	
	override func mouseEntered(at point: CGPoint) {
		//glowLayer.opacity = 1
		edgeLayer.opacity = 1
	}
	
	override func mouseMoved(at point: CGPoint) {
		CATransaction.withActionsDisabled {
			glowLayer.position = point
			// TODO: Should notchOutlineLayer work in notch coordinates (origin in upper-left)?
			//let layerPoint = CGPoint(x: point.x, y: edgeLayer.bounds.height - point.y)
			let layerPoint = CGPoint(x: point.x, y: 0)
			maskLayer.position = layerPoint
		}
	}
	
	override func mouseExited(at point: CGPoint) {
		//glowLayer.opacity = 0
		edgeLayer.opacity = 0
	}
}

/*
 NOTE: Saving this for later.
 
 if let sublayer = sublayer {
	 let cursor = NSCursor.current
	 let cursorSize = cursor.image.size
	 let hotSpot = cursor.hotSpot
	 
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
 }

 */
