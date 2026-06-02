//
//  MittEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 6/2/26.
//

import AppKit

class MittEffect: NotchEffect {

	var backgroundLayer: CALayer
	var ledLayers: [CALayer]
	var timer: Timer?
	
	let ledCount = 12
	let padding: CGFloat = 10

	let ledBounds = CGRect(origin: .zero, size: CGSize(width: 20, height: 20))

	private func ledImage(named name: String) -> CGImage? {
		let image = NSImage(named: name)!
		var proposedRect = ledBounds
		return image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
	}
	
	lazy var greenOffImage: CGImage? = {
		return ledImage(named: "LED-off")
	}()

	lazy var greenOnImage: CGImage? = {
		return ledImage(named: "LED-green")
	}()

	lazy var yellowOffImage: CGImage? = {
		return ledImage(named: "LED-off")
	}()

	lazy var yellowOnImage: CGImage? = {
		return ledImage(named: "LED-yellow")
	}()

	lazy var orangeOffImage: CGImage? = {
		return ledImage(named: "LED-off")
	}()

	lazy var orangeOnImage: CGImage? = {
		return ledImage(named: "LED-orange")
	}()

	lazy var redOffImage: CGImage? = {
		return ledImage(named: "LED-off")
	}()

	lazy var redOnImage: CGImage? = {
		return ledImage(named: "LED-red")
	}()

	lazy var purpleOffImage: CGImage? = {
		return ledImage(named: "LED-off")
	}()

	lazy var purpleOnImage: CGImage? = {
		return ledImage(named: "LED-purple")
	}()

	lazy var blueOffImage: CGImage? = {
		return ledImage(named: "LED-off")
	}()

	lazy var blueOnImage: CGImage? = {
		return ledImage(named: "LED-blue")
	}()

	lazy var whiteOffImage: CGImage? = {
		return ledImage(named: "LED-off")
	}()

	lazy var whiteOnImage: CGImage? = {
		return ledImage(named: "LED-white")
	}()

	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		self.ledLayers = []
		
		self.backgroundLayer = CALayer()

		super.init(with: parentLayer, in: parentView, of: parentWindow)

		configureSublayers()
	}
	
	deinit {
		self.ledLayers.removeAll()
	}
	
	var patternAddress = 0b0000_0000_0000_0000
	
	static let patternRom = [
		0b000000_000000,
		0b000001_100000,
		0b000011_110000,
		0b000111_111000,
		0b001111_111100,
		0b011111_111110,
		0b111111_111111,
		0b011111_111110,
		0b001111_111100,
		0b000111_111000,
		0b000011_110000,
		0b000001_100000,
		0b000000_000000,
	]
	+ Array(repeating: 0b0000_0000, count: 8)
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }

		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let ledSpacing = availableWidth / CGFloat(ledCount - 1)
		let yOffset = -ledBounds.height

		do { // the layer that is a frame holding the screen
			backgroundLayer.bounds = parentLayer.bounds
			backgroundLayer.backgroundColor = NSColor.darkGray.cgColor
			backgroundLayer.cornerRadius = CGFloat.notchLowerRadius
			backgroundLayer.masksToBounds = true
			backgroundLayer.contentsScale = parentLayer.contentsScale
			backgroundLayer.position = .zero
			backgroundLayer.anchorPoint = .zero
		}
		
		parentLayer.addSublayer(backgroundLayer)

		for index in 0..<ledCount {
			let ledLayer = CALayer()
			
			ledLayer.contentsScale = parentLayer.contentsScale

			ledLayer.bounds = ledBounds
			ledLayer.contents = switch (index) {
			case 0, 11:
				greenOffImage
			case 1, 10:
				yellowOffImage
			case 2, 9:
				orangeOffImage
			case 3, 8:
				redOffImage
			case 4, 7:
				purpleOffImage
			case 5, 6:
				blueOffImage
			default:
				whiteOffImage
			}
			
			ledLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
			
			let xOffset = padding + (ledSpacing * CGFloat(index))
			ledLayer.position = CGPoint(x: xOffset, y: backgroundLayer.bounds.midY)
			
			backgroundLayer.addSublayer(ledLayer)
			
			ledLayers.append(ledLayer)
		}
	}
	
	private func startLights() {
		if timer == nil {
			patternAddress = 0b0000_0000_0000_0000
			timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
				let pattern = Self.patternRom[self.patternAddress]
				
				var shift = pattern
				for index in 0..<self.ledCount {
					let ledLayer = self.ledLayers[index]
					
					let state = shift & 0b1000_0000_0000
					if (state == 0b0) {
						ledLayer.contents = switch (index) {
						case 0, 11:
							self.greenOffImage
						case 1, 10:
							self.yellowOffImage
						case 2, 9:
							self.orangeOffImage
						case 3, 8:
							self.redOffImage
						case 4, 7:
							self.purpleOffImage
						case 5, 6:
							self.blueOffImage
						default:
							self.whiteOffImage
						}
					}
					else {
						ledLayer.contents = switch (index) {
						case 0, 11:
							self.greenOnImage
						case 1, 10:
							self.yellowOnImage
						case 2, 9:
							self.orangeOnImage
						case 3, 8:
							self.redOnImage
						case 4, 7:
							self.purpleOnImage
						case 5, 6:
							self.blueOnImage
						default:
							self.whiteOnImage
						}
					}
					
					shift = shift << 1
				}
				
				self.patternAddress += 0b0000_0000_0000_0001
				if self.patternAddress >= Self.patternRom.count {
					self.patternAddress = 0b0000_0000_0000_0000
				}
			})
		}
	}

	//var lastPoint: CGPoint = .zero

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let yOffset = parentLayer.bounds.maxY

		stopLights()
		
		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.startLights()
		}

		for (index, ledLayer) in ledLayers.enumerated() {
			//ledLayer.contents = (index % 2 == 0 ? purpleOnImage : blueOnImage)
		}
		
			backgroundLayer.position = CGPoint(x: backgroundLayer.position.x, y: yOffset)
			
			let fromPosition: CGPoint
			if let position = backgroundLayer.presentation()?.position {
				fromPosition = position
			}
			else {
				fromPosition = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.minY)
			}
			
			let springDownAnimation = CASpringAnimation(keyPath: "position")
			springDownAnimation.fromValue = fromPosition
			springDownAnimation.toValue = CGPoint(x: backgroundLayer.position.x, y: yOffset)
			springDownAnimation.duration = 2
			springDownAnimation.damping = 8
			springDownAnimation.mass = 0.5
			backgroundLayer.add(springDownAnimation, forKey: "position")
		//}
		
		CATransaction.commit()
		
		//lastPoint = point
	}
	
	/*
	var currentBulbIndex = -1

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
			
		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let bulbSpacing = availableWidth / CGFloat(ledCount - 1)

		if underNotch {
			let bulbInset = padding - (bulbSpacing / 2)
			if point.x > bulbInset {
				let bulbIndex = Int((point.x - bulbInset) / bulbSpacing)
				if bulbIndex >= 0 && bulbIndex < ledCount {
					if bulbIndex != currentBulbIndex {
						currentBulbIndex = bulbIndex

						let ledLayer = ledLayers[bulbIndex]
						
						CATransaction.begin()
						
						let horizontalDirection = point.x - lastPoint.x // negative = moving left, positive - moving right
						let pulse: CGFloat = horizontalDirection > 0 ? -1 : 1
						let springSwayAnimation = CASpringAnimation(keyPath: "transform.rotation")
						springSwayAnimation.fromValue = CGFloat.pi / 16 * pulse
						springSwayAnimation.toValue = 0
						springSwayAnimation.duration = 3
						springSwayAnimation.damping = 2
						springSwayAnimation.fillMode = .forwards
						springSwayAnimation.isAdditive = true
						ledLayer.add(springSwayAnimation, forKey: "springSway")
						
						CATransaction.commit()
					}
				}
			}
		}
		else {
			currentBulbIndex = -1
		}
		
		lastPoint = point
	}
	*/
	
	private func stopLights() {
		timer?.invalidate()
		timer = nil
	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		//let yOffset = -ledBounds.height
		let yOffset = parentLayer.bounds.minY

		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.stopLights()
		}
		
		//ledLayers.forEach { ledLayer in
		//	ledLayer.position = CGPoint(x: ledLayer.position.x, y: yOffset)
		//}
		backgroundLayer.position = CGPoint(x: backgroundLayer.position.x, y: yOffset)

			let fromPosition: CGPoint
			if let position = backgroundLayer.presentation()?.position {
				fromPosition = position
			}
			else {
				fromPosition = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.maxY)
			}

			let animation = CABasicAnimation(keyPath: "position")
			animation.fromValue = fromPosition
			animation.toValue = CGPoint(x: backgroundLayer.position.x, y: yOffset)
			animation.duration = 1
			animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
			backgroundLayer.add(animation, forKey: "position")
		//}
		
		CATransaction.commit()
	}

}
