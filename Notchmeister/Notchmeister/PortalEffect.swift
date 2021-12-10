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
	
	let glowRadius = 60.0 // notch height is 38 pt, with 50 pt border
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
		
		do { // the glow around the cursor, to light your way
			let glowColor = NSColor(named: "glowEffect-glow")!
			
			let glowDimension = glowRadius * 2
			inGlowLayer.bounds = CGRect(origin: .zero, size: CGSize(width: glowDimension, height: glowDimension))
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

			let points = [0, 1.0/8.0, 2.0/8.0, 3.0/8.0, 4.0/8.0, 5.0/8.0, 6.0/8.0, 7.0/8.0, 8.0/8.0]
			let colors: [CGColor] = points.map { point in
				let attenuation = ((cos(.pi * point) - 1.0) / 2.0) + 1
				return glowColor.withAlphaComponent(attenuation).cgColor
			}
			let locations: [NSNumber] = points.map { point in
				return NSNumber(value: point)
			}
			
			inGlowLayer.type = .axial
			inGlowLayer.colors = colors
			inGlowLayer.locations = locations
			inGlowLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
			inGlowLayer.endPoint = CGPoint(x: 1,y: 1)
			
			parentLayer.addSublayer(inGlowLayer)
		}
		
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		inGlowLayer.opacity = 0

		// NOTE: We record the hot spot relative to the center of the cursor since we're dealing with layers
		// that want to be over the point of maximum luminence.
		let cursor = NSCursor.current
		let cursorBounds = CGRect(origin: .zero, size: cursor.image.size)
		let hotSpot = cursor.hotSpot
		hotSpotOffset = CGPoint(x: cursorBounds.midX - hotSpot.x, y: cursorBounds.midY - hotSpot.y)
	}
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		CATransaction.withActionsDisabled {
			if underNotch {
				let edgeDistance = edgeDistance(at: point)
				if edgeDistance > 0 {
					// NOTE: See note above about how the light is attenuated with exponential falloff.
					let normalizedEdgeDistance = Float(edgeDistance / maxEdgeDistance())
					inGlowLayer.opacity = 1.0 - (1.0 / 1.0 - normalizedEdgeDistance * normalizedEdgeDistance)
				}
				else {
					inGlowLayer.opacity = 0
				}
			}
			else {
				inGlowLayer.opacity = 0
			}
		
			inGlowLayer.position = point + hotSpotOffset
			
//			if let debugLayer = debugLayer {
//				debugLayer.position = point + hotSpotOffset
//			}
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		inGlowLayer.opacity = 0
	}
}
