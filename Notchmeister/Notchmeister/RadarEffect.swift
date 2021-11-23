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
			screenLayer.position = CGPoint(x: screenLayer.bounds.midX, y: screenLayer.bounds.midY)
	//		screenLayer.anchorPoint = .zero //CGPoint(x: 0.5, y: 0.5)
			screenLayer.backgroundColor = NSColor.black.cgColor
			screenLayer.cornerRadius = CGFloat.notchLowerRadius
			screenLayer.opacity = 0.5
			
			//var proposedRect: CGRect? = nil
			screenLayer.contents = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
		}
		
		do { // the layer that is a frame holding the screen
			frameLayer.bounds = radarLayer.bounds
			frameLayer.borderWidth = 2
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

}
