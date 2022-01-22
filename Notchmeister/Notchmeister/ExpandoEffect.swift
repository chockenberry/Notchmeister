//
//  ExpandoEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 1/21/22.
//

import AppKit

class ExpandoEffect: NotchEffect {
	
	var edgeLayer: CAShapeLayer

	required init (with parentLayer: CALayer, in parentView: NSView) {
		self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size, flipped: true)
		
		super.init(with: parentLayer, in: parentView)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		
		do { // the edge highlight, for that high-tech sheen
			//let edgeColor = NSColor(named: "glowEffect-edge")!
			
			edgeLayer.anchorPoint = .zero
			if Defaults.shouldDebugDrawing {
				edgeLayer.fillColor = NSColor.systemRed.cgColor
			}
			else {
				edgeLayer.fillColor = NSColor.black.cgColor
			}
			edgeLayer.opacity = 0
			
			parentLayer.addSublayer(edgeLayer)
		}
	}

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		edgeLayer.opacity = 1
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		//CATransaction.withActionsDisabled {
		do {
			if underNotch {
				let edgeDistance = edgeDistance(at: point)
				if edgeDistance > 0 {
					// NOTE: See note above about how the light is attenuated with exponential falloff.
					let normalizedEdgeDistance = Float(edgeDistance / maxEdgeDistance())
					let scale = CGFloat(1.0 + (normalizedEdgeDistance / 4))
					let horizontalPosition = (point.x - parentLayer.bounds.midX) / 5
					let scaleTransform = CATransform3DMakeScale(scale, scale, 1)
					let translateTransform = CATransform3DMakeTranslation(horizontalPosition, 0, 1)
					//let transform = CATransform3DTranslate(scaleTransform, horizontalPosition, 0, 0)
					let transform = CATransform3DScale(translateTransform, scale, scale, 1)
					edgeLayer.transform = transform
				}
				else {
					let transform = CATransform3DMakeScale(1, 1, 1)
					edgeLayer.transform = transform
				}
			}
			else {
				let transform = CATransform3DMakeScale(1, 1, 1)
				edgeLayer.transform = transform
			}
		}

	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		edgeLayer.opacity = 0
	}

}

