//
//  RadarEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/22/21.
//

import AppKit

class RadarEffect: NotchEffect {
	
	//let context = CIContext(options: nil)

	var radarLayer: CATransformLayer
	var screenLayer: CALayer

	required init(with parentLayer: CALayer) {
		self.radarLayer = CATransformLayer()
		self.screenLayer = CALayer()

		super.init(with: parentLayer)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		radarLayer.bounds = parentLayer.bounds
//		radarLayer.masksToBounds = true
		radarLayer.contentsScale = parentLayer.contentsScale
		radarLayer.position = CGPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.maxY)

		radarLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
//		radarLayer.backgroundColor = NSColor.black.cgColor
//		radarLayer.cornerRadius = CGFloat.notchLowerRadius
		
		radarLayer.transform = CATransform3DMakeRotation(-.pi/2, 1, 0, 0)
//		radarLayer.opacity = 1
		
		screenLayer.bounds = radarLayer.bounds
		screenLayer.masksToBounds = true
		screenLayer.contentsScale = radarLayer.contentsScale
		screenLayer.position = .zero
		screenLayer.anchorPoint = CGPoint(x: 0, y: 0)
		screenLayer.backgroundColor = NSColor.black.cgColor
		screenLayer.cornerRadius = CGFloat.notchLowerRadius
		screenLayer.opacity = 1
		
		let image = NSImage(named: "xray")!
		var proposedRect = radarLayer.bounds
		screenLayer.contents = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)

		radarLayer.addSublayer(screenLayer)
		
		parentLayer.addSublayer(radarLayer)
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
	}

	var wasUnderNotch = false
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		if underNotch != wasUnderNotch {
			CATransaction.begin()
			CATransaction.setCompletionBlock { [weak self] in
				//self?.startLights()
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
			
//			if underNotch {
//				radarLayer.zPosition = 1
//			}
//			else {
//				radarLayer.zPosition = 0
//			}
			
			wasUnderNotch = underNotch
		}
		
//		if underNotch {
//			radarLayer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
//		}
//		else {
//			radarLayer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
//		}
	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
	}

}
