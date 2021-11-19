//
//  FestiveEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/16/21.
//

import AppKit

class FestiveEffect: NotchEffect {
	
	//let context = CIContext(options: nil)

	var bulbLayers: [CALayer]
	
	let bulbCount = 12
	let padding: CGFloat = 10
	
	required init(with parentLayer: CALayer) {
		self.bulbLayers = []
		
		super.init(with: parentLayer)

		configureSublayers()
	}
	
	deinit {
		self.bulbLayers.removeAll()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }

		let bulbSize = CGSize(width: 15, height: 55)
		let bulbBounds = CGRect(origin: .zero, size: bulbSize)

		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let bulbSpacing = availableWidth / CGFloat(bulbCount - 1)
		let yOffset = -bulbBounds.height

		
		let image = NSImage(named: "bulb")!
		var proposedRect = bulbBounds
		let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)

		for i in 0..<bulbCount {
			let bulbLayer = CALayer()
			
			bulbLayer.contentsScale = parentLayer.contentsScale

			bulbLayer.bounds = bulbBounds
			bulbLayer.contents = cgImage
			
			bulbLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
			
			let xOffset = padding + (bulbSpacing * CGFloat(i))
			bulbLayer.position = CGPoint(x: xOffset, y: yOffset)
			
			//bulbLayer.transform = CATransform3DMakeRotation(.pi/8, 0, 0, 1)
			//bulbLayer.backgroundColor = NSColor.yellow.cgColor
			
			parentLayer.addSublayer(bulbLayer)
			
			bulbLayers.append(bulbLayer)
		}
	}
	
	override func start() {
	}

	override func end() {
	}

	var lastPoint: CGPoint = .zero

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let yOffset = parentLayer.bounds.midY

		let bulbSize = CGSize(width: 15, height: 55)
		let bulbBounds = CGRect(origin: .zero, size: bulbSize)

		CATransaction.begin()

		bulbLayers.forEach { bulbLayer in
			bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)
			
			let springDownAnimation = CASpringAnimation(keyPath: "position")
			springDownAnimation.fromValue = CGPoint(x: bulbLayer.position.x, y: -bulbBounds.height)
			springDownAnimation.toValue = CGPoint(x: bulbLayer.position.x, y: yOffset)
			springDownAnimation.duration = 3
			springDownAnimation.damping = 8
			springDownAnimation.mass = 0.5
			//springDownAnimation.fillMode = .forwards
			//springDownAnimation.isRemovedOnCompletion = false
			//bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)
			bulbLayer.add(springDownAnimation, forKey: "presentation")
		}
		
		CATransaction.commit()
		
		lastPoint = point
	}
	
	var currentBulbIndex = -1
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
		
		//let parentLayer.bounds.width / CGFloat(bulbCount)
	
		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let bulbSpacing = availableWidth / CGFloat(bulbCount - 1)

		if underNotch {
			if point.x > padding {
				let bulbIndex = Int((point.x - padding) / bulbSpacing)
				if bulbIndex != currentBulbIndex {
					currentBulbIndex = bulbIndex
					debugLog("starting bulbIndex = \(bulbIndex)")
					let bulbLayer = bulbLayers[bulbIndex]
					
					//if bulbLayer.animation(forKey: "springSway") == nil {
					CATransaction.begin()
					
					//bulbLayer.removeAnimation(forKey: "springSway")
					//bulbLayer.removeAnimation(forKey: "springOut")
					
//let springOutAnimation = CASpringAnimation(keyPath: "transform.scale")
//springOutAnimation.fromValue = 1.1
//springOutAnimation.toValue = 1.0
//springOutAnimation.duration = 3
//springOutAnimation.damping = 5
//springOutAnimation.fillMode = .forwards
////springAnimation.autoreverses = true
//
//CATransaction.setCompletionBlock { [weak self] in
//	debugLog("finished bulbIndex = \(bulbIndex)")
					let horizontalDirection = point.x - lastPoint.x // negative = moving left, positive - moving right
					let pulse: CGFloat = horizontalDirection > 0 ? -1 : 1
					let springSwayAnimation = CASpringAnimation(keyPath: "transform.rotation")
					springSwayAnimation.fromValue = CGFloat.pi / 36 * pulse
					springSwayAnimation.toValue = 0
					springSwayAnimation.duration = 3
					springSwayAnimation.damping = 5
					springSwayAnimation.fillMode = .forwards
					springSwayAnimation.isAdditive = true
					bulbLayer.add(springSwayAnimation, forKey: "springSway")
//}
//
//bulbLayer.add(springOutAnimation, forKey: "springOut")
					CATransaction.commit()
					//}
				}
			}
		}
		else {
			currentBulbIndex = -1
		}
		
		lastPoint = point
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let bulbSize = CGSize(width: 15, height: 55)
		let bulbBounds = CGRect(origin: .zero, size: bulbSize)
		let yOffset = -bulbBounds.height

		CATransaction.begin()

		bulbLayers.forEach { bulbLayer in
			bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)
			
			let animation = CABasicAnimation(keyPath: "position")
			animation.fromValue = CGPoint(x: bulbLayer.position.x, y: parentLayer.bounds.midY)
			animation.toValue = CGPoint(x: bulbLayer.position.x, y: -bulbBounds.height)
			animation.duration = 1
			animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
			bulbLayer.add(animation, forKey: "presentation")
		}
		
		CATransaction.commit()

//		bulbLayers.forEach { bulbLayer in
//			bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)
//
//		}
	}

}
