//
//  ExpandoEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 1/21/22.
//

import AppKit

class ExpandoEffect: NotchEffect {
	
	var edgeLayer: CAShapeLayer

	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size, flipped: true)

		super.init(with: parentLayer, in: parentView, of: parentWindow)


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
					let bounds = parentLayer.bounds
					let normalizedPoint = CGPoint(x: point.x / bounds.width, y: 1.0 - (point.y / bounds.height))
					//debugLog("normalizedPoint = \(normalizedPoint)")
					// x: 0 = left edge, 1 = right edge
					// y: 0 = bottom edge, 1 = top edge
						
					let scale = 1.25
					let scaledWidth = bounds.width * scale
					let horizontalPosition = ((bounds.width * normalizedPoint.x) + ((bounds.width * (1.0 - normalizedPoint.x)) * scale)) - scaledWidth
					let translateTransform = CATransform3DMakeTranslation(horizontalPosition, 0, 1)
					let verticalScale: CGFloat
					if normalizedPoint.y > 0.5 {
						verticalScale = 1.0 + (0.5 * (normalizedPoint.y - 0.5))
					}
					else {
						verticalScale = 1.0
					}
					let transform = CATransform3DScale(translateTransform, scale, verticalScale, 1)
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

