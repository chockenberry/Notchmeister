//
//  RadarEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/22/21.
//

import AppKit

class RadarEffect: NotchEffect {
	
	//let context = CIContext(options: nil)

	var radarLayer: CALayer

	required init(with parentLayer: CALayer) {
		self.radarLayer = CALayer()
		
		super.init(with: parentLayer)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		radarLayer.bounds = parentLayer.bounds
		radarLayer.masksToBounds = true
		radarLayer.contentsScale = parentLayer.contentsScale
		radarLayer.position = CGPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.maxY)

		radarLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
		radarLayer.backgroundColor = NSColor.black.cgColor
		radarLayer.cornerRadius = CGFloat.notchLowerRadius
		
		radarLayer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
		radarLayer.opacity = 1
		
		let image = NSImage(named: "xray")!
		var proposedRect = radarLayer.bounds
		radarLayer.contents = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)

		parentLayer.addSublayer(radarLayer)
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		if underNotch {
			radarLayer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
		}
		else {
			radarLayer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
		}
	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
	}

}
