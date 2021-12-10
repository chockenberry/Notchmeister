//
//  PortalEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 12/9/21.
//

import AppKit

class PortalEffect: NotchEffect {
	
	var inGlowLayer: CAGradientLayer
	var outGlowLayer: CAGradientLayer

	var hotSpotOffset: CGPoint = .zero
	
	let glowSize = CGSize(width: 10, height: 20)
	let maskRadius = 12.0 // cursor radius is 23 pt / 2 = 11.5
	let edgeWidth = 1.0
	let offset = 0
	
	required init (with parentLayer: CALayer, in parentView: NSView) {
		self.inGlowLayer = CAGradientLayer()
		self.outGlowLayer = CAGradientLayer()

		if Defaults.shouldDebugDrawing {
		}
		
		super.init(with: parentLayer, in: parentView)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		do {
			let glowColor = NSColor(named: "portalEffect-in")!
			
			inGlowLayer.bounds = CGRect(origin: .zero, size: glowSize)
			inGlowLayer.masksToBounds = false
			if Defaults.shouldDebugDrawing {
				inGlowLayer.backgroundColor = NSColor.systemBlue.cgColor
			}
			else {
				inGlowLayer.backgroundColor = NSColor.clear.cgColor
			}
			inGlowLayer.contentsScale = parentLayer.contentsScale
			inGlowLayer.position = .zero
			inGlowLayer.opacity = 0
			
			// NOTE: The glow gradient is drawn with sinusoidal falloff at eight equidistant points along the radius.
			// Exponential falloff is more physically accurate, but gets lost in the user interface.

			let points = [0.0, 0.25, 1.0]
			let colors: [CGColor] = points.map { point in
				let attenuation = point
				return glowColor.withAlphaComponent(attenuation).cgColor
			}
			let locations: [NSNumber] = points.map { point in
				return NSNumber(value: point)
			}
			
			inGlowLayer.type = .axial
			inGlowLayer.colors = colors
			inGlowLayer.locations = locations
			inGlowLayer.startPoint = CGPoint(x: 0, y: 0)
			inGlowLayer.endPoint = CGPoint(x: 1, y: 0)
			
			inGlowLayer.anchorPoint = CGPoint(x: 1, y: 0.5)
			inGlowLayer.position = CGPoint(x: 0, y: parentLayer.bounds.midY)
			
			parentLayer.addSublayer(inGlowLayer)

			inGlowLayer.transform = CATransform3DMakeRotation(.pi, 0, 0, 0)
		}
	
		do {
			let glowColor = NSColor(named: "portalEffect-out")!
			
			outGlowLayer.bounds = CGRect(origin: .zero, size: glowSize)
			outGlowLayer.masksToBounds = false
			if Defaults.shouldDebugDrawing {
				outGlowLayer.backgroundColor = NSColor.systemBlue.cgColor
			}
			else {
				outGlowLayer.backgroundColor = NSColor.clear.cgColor
			}
			outGlowLayer.contentsScale = parentLayer.contentsScale
			outGlowLayer.position = .zero
			outGlowLayer.opacity = 0
			
			// NOTE: The glow gradient is drawn with sinusoidal falloff at eight equidistant points along the radius.
			// Exponential falloff is more physically accurate, but gets lost in the user interface.

			let points = [0.0, 0.25, 1.0]
			let colors: [CGColor] = points.map { point in
				let attenuation = point
				return glowColor.withAlphaComponent(attenuation).cgColor
			}
			let locations: [NSNumber] = points.map { point in
				return NSNumber(value: point)
			}
			
			outGlowLayer.type = .axial
			outGlowLayer.colors = colors
			outGlowLayer.locations = locations
			outGlowLayer.startPoint = CGPoint(x: 0, y: 0)
			outGlowLayer.endPoint = CGPoint(x: 1, y: 0)
			
			outGlowLayer.anchorPoint = CGPoint(x: 1, y: 0.5)
			
			parentLayer.addSublayer(outGlowLayer)

			outGlowLayer.position = CGPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.maxY)
			outGlowLayer.transform = CATransform3DMakeRotation(.pi, 1, -1, 0)
		}

	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		//inGlowLayer.opacity = 1
		//outGlowLayer.opacity = 1

		let pulseAnimation = CABasicAnimation(keyPath: "opacity")
		pulseAnimation.fromValue = 0.25
		pulseAnimation.toValue = 1.0
		pulseAnimation.duration = 0.25
		pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		pulseAnimation.autoreverses = true
		pulseAnimation.repeatCount = .greatestFiniteMagnitude
		inGlowLayer.add(pulseAnimation, forKey: "opacity")
		outGlowLayer.add(pulseAnimation, forKey: "opacity")

		// NOTE: We record the hot spot relative to the center of the cursor since we're dealing with layers
		// that want to be over the point of maximum luminence.
		let cursor = NSCursor.current
		let cursorBounds = CGRect(origin: .zero, size: cursor.image.size)
		let hotSpot = cursor.hotSpot
		hotSpotOffset = CGPoint(x: cursorBounds.midX - hotSpot.x, y: cursorBounds.midY - hotSpot.y)
	}
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		CATransaction.withActionsDisabled {

//			inGlowLayer.position = point + hotSpotOffset
			
//			if let debugLayer = debugLayer {
//				debugLayer.position = point + hotSpotOffset
//			}
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		let currentOpacity = inGlowLayer.presentation()?.opacity
		
		inGlowLayer.removeAnimation(forKey: "opacity")
		outGlowLayer.removeAnimation(forKey: "opacity")

		inGlowLayer.opacity = 0
		outGlowLayer.opacity = 0
		
		let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
		fadeOutAnimation.fromValue = currentOpacity
		fadeOutAnimation.toValue = 0
		fadeOutAnimation.duration = 0.5
		fadeOutAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		fadeOutAnimation.isRemovedOnCompletion = true
		inGlowLayer.add(fadeOutAnimation, forKey: "opacity")
		outGlowLayer.add(fadeOutAnimation, forKey: "opacity")
	}
}
