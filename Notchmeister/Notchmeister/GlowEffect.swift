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
	
	let glowRadius = 40.0 // notch height is 38 pt
	let maskRadius = 12.0 // cursor radius is 23 pt / 2 = 11.5
	let edgeWidth = 1.0
	let offset = 0
	
	required init(with parentLayer: CALayer) {
		self.glowLayer = CAGradientLayer()
		self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size, flipped: true)
		self.maskLayer = CAGradientLayer()

		if Defaults.shouldDebugDrawing {
			self.debugLayer = CALayer()
		}
		
		super.init(with: parentLayer)

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
			
			glowLayer.type = .radial
			let startColor = glowColor
			let endColor = glowColor.withAlphaComponent(0)
			glowLayer.colors = [startColor.cgColor, startColor.cgColor, endColor.cgColor]
			glowLayer.locations = [0, 0.25, 1]
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
					// TODO: add some non-linear interpolation for the glow intensity
					glowLayer.opacity = Float(edgeDistance / maxEdgeDistance())
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
