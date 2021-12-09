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
	var debugLayer: CALayer?

	var hotSpotOffset: CGPoint = .zero
	
//	let glowRadius = 100.0 // notch height is 38 pt
	let glowRadius = 60.0 // notch height is 38 pt, with 50 pt border
	let maskRadius = 12.0 // cursor radius is 23 pt / 2 = 11.5
	let edgeWidth = 1.0
	let offset = 0
	
	required init (with parentLayer: CALayer, in parentView: NSView) {
		self.glowLayer = CAGradientLayer()
		self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size, flipped: true)
		self.maskLayer = CAGradientLayer()

		if Defaults.shouldDebugDrawing {
			self.debugLayer = CALayer()
		}
		
		super.init(with: parentLayer, in: parentView)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		do { // the glow around the cursor, to light your way
			let glowColor = NSColor(named: "glowEffect-glow")!
			
			let glowDimension = glowRadius * 2
			glowLayer.bounds = CGRect(origin: .zero, size: CGSize(width: glowDimension, height: glowDimension))
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
			
#if false
			// NOTE: The glow gradient is drawn with exponential falloff at eight equidistant points along the radius
			// (to simulate a single point of light). There is also an exponential falloff on the layer opacity
			// as the mouse gets closer to the edge. See Glow.gcx for how this is modeled.
			//
			// Also, this explanation of light attenuation on StackOverflow was super helpful:
			// https://gamedev.stackexchange.com/a/131383
			
			let points = [0, 1.0/8.0, 2.0/8.0, 3.0/8.0, 4.0/8.0, 5.0/8.0, 6.0/8.0, 7.0/8.0]
			let a = 0.0
			let b = 80.0 // 100.0 is more physically accurate, but harder to see. So...
			var colors: [CGColor] = points.map { point in
				let attenuation = 1.0 / (1.0 - a * point + b * point * point)
				//let attenuation = 1.0 / 1.0 - point * point
				return glowColor.withAlphaComponent(attenuation).cgColor
			}
			colors.append(glowColor.withAlphaComponent(0).cgColor)
			var locations: [NSNumber] = points.map { point in
				return NSNumber(value: point)
			}
			locations.append(NSNumber(value: 1))
#else
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
#endif
			
			glowLayer.type = .radial
//			let startColor = glowColor
//			let middleColor = glowColor.withAlphaComponent(0.5)
//			let endColor = glowColor.withAlphaComponent(0)
//			glowLayer.colors = [startColor.cgColor, middleColor.cgColor, endColor.cgColor]
//			glowLayer.locations = [0, 0.25, 1]
			glowLayer.colors = colors
			glowLayer.locations = locations
			glowLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
			glowLayer.endPoint = CGPoint(x: 1,y: 1)
			
			parentLayer.addSublayer(glowLayer)
		}
		
		do { // the edge highlight, for that high-tech sheen
			let edgeColor = NSColor(named: "glowEffect-edge")!
			
			edgeLayer.anchorPoint = .zero
			edgeLayer.fillColor = NSColor.clear.cgColor
			edgeLayer.strokeColor = edgeColor.cgColor
			edgeLayer.lineWidth = edgeWidth * 2
			edgeLayer.opacity = 0

			let maskDimension = maskRadius * 2
			maskLayer.bounds = CGRect(origin: .zero, size: CGSize(width: maskDimension, height: maskDimension))
			maskLayer.type = .radial
			let startColor = NSColor.white
			let endColor = startColor.withAlphaComponent(0)
			maskLayer.colors = [startColor.cgColor, startColor.cgColor, endColor.cgColor]
			maskLayer.locations = [0, 0.75, 1]
			maskLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
			maskLayer.endPoint = CGPoint(x: 1,y: 1)
			maskLayer.position = .zero
			
			edgeLayer.mask = maskLayer
			
			parentLayer.addSublayer(edgeLayer)
		}
		
		if let debugLayer = debugLayer {
			debugLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 38, height: 38))
			debugLayer.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.25).cgColor

			parentLayer.addSublayer(debugLayer)
		}
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		glowLayer.opacity = 0
		edgeLayer.opacity = 1 // .. and probably completely masked out

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
					glowLayer.opacity = 1.0 - (1.0 / 1.0 - normalizedEdgeDistance * normalizedEdgeDistance)
				}
				else {
					glowLayer.opacity = 0
				}
			}
			else {
				glowLayer.opacity = 0
			}

			//debugLog("edgeDistance = \(edgeDistance(at: point))")
		
			glowLayer.position = point + hotSpotOffset
			maskLayer.position = point + hotSpotOffset
			
			if let debugLayer = debugLayer {
				debugLayer.position = point + hotSpotOffset
			}
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		glowLayer.opacity = 0
		edgeLayer.opacity = 0
	}
}
