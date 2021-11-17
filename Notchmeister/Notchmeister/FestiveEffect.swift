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
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let yOffset = parentLayer.bounds.midY

		bulbLayers.forEach { bulbLayer in
			bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)
		}
	}
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
		
		//let parentLayer.bounds.width / CGFloat(bulbCount)
	
		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let bulbSpacing = availableWidth / CGFloat(bulbCount - 1)

		if underNotch {
			if point.x > padding {
				let bulbIndex = Int((point.x - padding) / bulbSpacing)
				debugLog("bulbIndex = \(bulbIndex)")
				let bulbLayer = bulbLayers[bulbIndex]
				
				let springAnimation = CASpringAnimation(keyPath: "transform.scale")
				springAnimation.fromValue = 1.0
				springAnimation.toValue = 1.1
				springAnimation.duration = 2.0
				springAnimation.damping = 5
				springAnimation.autoreverses = true
				
				bulbLayer.add(springAnimation, forKey: "transform.scale")
			}
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let bulbSize = CGSize(width: 15, height: 55)
		let bulbBounds = CGRect(origin: .zero, size: bulbSize)
		let yOffset = -bulbBounds.height

		bulbLayers.forEach { bulbLayer in
			bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)
		}
	}

}
