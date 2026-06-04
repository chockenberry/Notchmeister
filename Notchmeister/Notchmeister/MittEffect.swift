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
	var speechSynthesizerLevelsNotificationObserver: NSObjectProtocol? = nil

	let ledCount = 12
	let padding: CGFloat = 15

	let ledBounds = CGRect(origin: .zero, size: CGSize(width: 15, height: 15))

	lazy var mittStorage: [String] = {
		if let path = Bundle.main.path(forResource: "mitt-storage", ofType: "txt") {
			if let text = try? String(contentsOfFile: path, encoding: .utf8) {
				let lines = text.split(separator: "\n")
				var result = [String]()
				for line in lines {
					if !line.isEmpty && !line.starts(with: "#") {
						result.append(String(line))
					}
				}
#if DEBUG && true
				return result
#else
				return result.shuffled()
#endif
			}
		}

		return ["MITT Storage Offline"]
	}()
	
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
		
		self.speechSynthesizerLevelsNotificationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.speechSynthesizerLevelDidChange, object: nil, queue: nil) { [weak self] note in
			if let self = self {
				self.updateLeds()
			}
		}
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

		do { // the layer that is a frame holding the screen
			backgroundLayer.bounds = parentLayer.bounds
#if DEBUG && true
			backgroundLayer.backgroundColor = NSColor.darkGray.cgColor
#else
			backgroundLayer.backgroundColor = NSColor.black.cgColor
#endif
			backgroundLayer.cornerRadius = parentLayer.bounds.height / 2
			backgroundLayer.masksToBounds = true
			backgroundLayer.contentsScale = parentLayer.contentsScale
			backgroundLayer.position = .zero
			backgroundLayer.anchorPoint = .zero
		}
		
		parentLayer.addSublayer(backgroundLayer)

		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let ledSpacing = availableWidth / CGFloat(ledCount - 1)

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
	
	private func resetLedLayers(leftIndex: Int, rightIndex: Int, offImage: CGImage?) {
		let leftLedLayer = ledLayers[leftIndex]
		let rightLedLayer = ledLayers[rightIndex]

		leftLedLayer.contents = offImage
		rightLedLayer.contents = offImage
	}

	private func updateLedLayers(leftIndex: Int, rightIndex: Int, level: Float, cutoffLevel: Float, onImage: CGImage?, offImage: CGImage?) {
		let leftLedLayer = ledLayers[leftIndex]
		let rightLedLayer = ledLayers[rightIndex]
		if level < cutoffLevel {
			leftLedLayer.contents = onImage
			rightLedLayer.contents = onImage
		}
		else {
			leftLedLayer.contents = offImage
			rightLedLayer.contents = offImage
		}
	}

	private func updateLeds() {
		let level = SpeechSynthesizer.shared.level

		let greenCutoffLevel: Float = -45.0
		let yellowCutoffLevel: Float = -40.0
		let orangeCutoffLevel: Float = -35.0
		let redCutoffLevel: Float = -30.0
		let purpleCutoffLevel: Float = -25.0
		let blueCutoffLevel: Float = -20.0

		if level.isInfinite {
			resetLedLayers(leftIndex: 0, rightIndex: 11, offImage: greenOffImage)
			resetLedLayers(leftIndex: 1, rightIndex: 10, offImage: yellowOffImage)
			resetLedLayers(leftIndex: 2, rightIndex: 9, offImage: orangeOffImage)
			resetLedLayers(leftIndex: 3, rightIndex: 8, offImage: redOffImage)
			resetLedLayers(leftIndex: 4, rightIndex: 7, offImage: purpleOffImage)
			resetLedLayers(leftIndex: 5, rightIndex: 6, offImage: blueOffImage)
		}
		else {
			updateLedLayers(leftIndex: 0, rightIndex: 11, level: level, cutoffLevel: greenCutoffLevel, onImage: greenOnImage, offImage: greenOffImage)
			updateLedLayers(leftIndex: 1, rightIndex: 10, level: level, cutoffLevel: yellowCutoffLevel, onImage: yellowOnImage, offImage: yellowOffImage)
			updateLedLayers(leftIndex: 2, rightIndex: 9, level: level, cutoffLevel: orangeCutoffLevel, onImage: orangeOnImage, offImage: orangeOffImage)
			updateLedLayers(leftIndex: 3, rightIndex: 8, level: level, cutoffLevel: redCutoffLevel, onImage: redOnImage, offImage: redOffImage)
			updateLedLayers(leftIndex: 4, rightIndex: 7, level: level, cutoffLevel: purpleCutoffLevel, onImage: purpleOnImage, offImage: purpleOffImage)
			updateLedLayers(leftIndex: 5, rightIndex: 6, level: level, cutoffLevel: blueCutoffLevel, onImage: blueOnImage, offImage: blueOffImage)
		}
	}
	
	/*
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
	*/
	
	var textIndex = 0
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
		
		let yOffset = parentLayer.bounds.maxY
		
		//stopLights()
		
		CATransaction.begin()
//		CATransaction.setCompletionBlock { [weak self] in
//			self?.startLights()
//		}
		CATransaction.setCompletionBlock {
			let speechSynthesizer = SpeechSynthesizer.shared
			if !speechSynthesizer.isSpeaking {
				//speechSynthesizer.speak("MITT System Activated - Auto Cruise Engaged")
				//speechSynthesizer.speak("This is a test. For the next sixty seconds, this Mac will conduct a test of its Emergency Broadcast System. This is only a test --- Beep. Boop.")
				//let textIndex = Int.random(in: 0..<self.mittStorage.count)
				let text = self.mittStorage[self.textIndex]
				speechSynthesizer.speak(text)
				self.textIndex += 1
				if self.textIndex >= self.mittStorage.count {
					self.textIndex = 0
				}
			}
}
		resetLedLayers(leftIndex: 0, rightIndex: 11, offImage: greenOffImage)
		resetLedLayers(leftIndex: 1, rightIndex: 10, offImage: yellowOffImage)
		resetLedLayers(leftIndex: 2, rightIndex: 9, offImage: orangeOffImage)
		resetLedLayers(leftIndex: 3, rightIndex: 8, offImage: redOffImage)
		resetLedLayers(leftIndex: 4, rightIndex: 7, offImage: purpleOffImage)
		resetLedLayers(leftIndex: 5, rightIndex: 6, offImage: blueOffImage)

		backgroundLayer.position = CGPoint(x: backgroundLayer.position.x, y: yOffset)
		
		let fromPosition: CGPoint
		if let position = backgroundLayer.presentation()?.position {
			fromPosition = position
		}
		else {
			fromPosition = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.minY)
		}
		
		let animation = CABasicAnimation(keyPath: "position")
		animation.fromValue = fromPosition
		animation.toValue = CGPoint(x: backgroundLayer.position.x, y: yOffset)
		animation.duration = 0.25
		animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		backgroundLayer.add(animation, forKey: "position")
		
		CATransaction.commit()
	}
	
	/*
	private func stopLights() {
		timer?.invalidate()
		timer = nil
	}
	*/
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
		
		let yOffset = parentLayer.bounds.minY
		
		CATransaction.begin()
//		CATransaction.setCompletionBlock { [weak self] in
//			self?.stopLights()
//		}
		
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
		animation.duration = 0.25
		animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		backgroundLayer.add(animation, forKey: "position")
		
		CATransaction.commit()
	}

}
