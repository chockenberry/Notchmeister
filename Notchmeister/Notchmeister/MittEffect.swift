//
//  MittEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 6/2/26.
//

import AppKit

class MittEffect: NotchEffect {

	// NOTE: The shutdown timer and index into the phrase storage are shared amongst multiple instances (which can occur
	// if there is more than one display with an notch).
	static var timer: Timer?
	static var currentStorageIndex = 0

	var backgroundLayer: CALayer
	var ledLayers: [CALayer]
	var speechSynthesizerLevelsNotificationObserver: NSObjectProtocol? = nil

	let ledCount = 12
	let padding: CGFloat = 15

	let ledBounds = CGRect(origin: .zero, size: CGSize(width: 15, height: 15))

	static let storageName = "MITT-Storage.txt"
	
	lazy var mittStorage: [String] = {
		let fullUserName = ProcessInfo.processInfo.fullUserName
		let firstName = fullUserName.split(separator: " ").first ?? "Michael"
		
		let fileManager = FileManager.default
		
		let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		if let applicationSupportDirectory = urls.first {
			let fileURL = applicationSupportDirectory.appendingPathComponent(Self.storageName, conformingTo: .plainText)
			let filePath = fileURL.path
			if !fileManager.fileExists(atPath: filePath) {
				if let resourcePath = Bundle.main.path(forResource: "mitt-storage", ofType: "txt") {
					try? fileManager.copyItem(atPath: resourcePath, toPath: filePath)
				}
			}
			
			if let text = try? String(contentsOfFile: filePath, encoding: .utf8) {
				let lines = text.split(separator: "\n")
				var result = [String]()
				for line in lines {
					if !line.isEmpty && !line.starts(with: "#") {
						if line.contains("{name}") {
							let personalizedLine = line.replacingOccurrences(of: "{name}", with: firstName)
							result.append(personalizedLine)
						}
						else {
							result.append(String(line))
						}
					}
				}
#if DEBUG && true
				// leave results in file order
#else
				result.shuffle()
#endif
				result.insert("I am the voice of Macintosh Interface Two Thousand's microprocessor. M.I.T.T - or MITT if you prefer.", at: 0)
				return result;
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
		self.backgroundLayer.removeFromSuperlayer()
	}
		
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }

		do { // the layer that is a frame holding the screen
			backgroundLayer.bounds = parentLayer.bounds
#if DEBUG && true
			var bounds = parentLayer.bounds
			bounds.size.height = 50

			backgroundLayer.bounds = bounds

			backgroundLayer.backgroundColor = NSColor(red: 0.84, green: 0.79, blue: 0.66, alpha: 1).cgColor
			backgroundLayer.cornerRadius = 4
#else
			backgroundLayer.bounds = parentLayer.bounds
			backgroundLayer.backgroundColor = NSColor.black.cgColor
			backgroundLayer.cornerRadius = parentLayer.bounds.height / 2
#endif
			backgroundLayer.masksToBounds = true
			backgroundLayer.contentsScale = parentLayer.contentsScale
			backgroundLayer.position = CGPoint(x: 0, y: parentLayer.bounds.minY - backgroundLayer.bounds.height)
			backgroundLayer.anchorPoint = .zero
		}
		
		parentLayer.addSublayer(backgroundLayer)

		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let ledSpacing = availableWidth / CGFloat(ledCount - 1)

		for index in 0..<ledCount {
			let ledLayer = CALayer()
			
			ledLayer.contentsScale = parentLayer.contentsScale
			ledLayer.bounds = ledBounds
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

#if DEBUG && true
		let greenCutoffLevel: Float = -40.0
		let yellowCutoffLevel: Float = -35.0
		let orangeCutoffLevel: Float = -30.0
		let redCutoffLevel: Float = -25.0
		let purpleCutoffLevel: Float = -20.0
		let blueCutoffLevel: Float = -15.0
#else
		let greenCutoffLevel: Float = -40.0
		let yellowCutoffLevel: Float = -35.0
		let orangeCutoffLevel: Float = -30.0
		let redCutoffLevel: Float = -25.0
		let purpleCutoffLevel: Float = -20.0
		let blueCutoffLevel: Float = -15.0
#endif
		
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
	
	private func startSpeechSynthesizer() {
		if Self.timer != nil {
			Self.timer?.invalidate()
		}
		SpeechSynthesizer.shared.startMonitoring()
	}

	private func stopSpeechSynthesizer() {
		if Self.timer != nil {
			Self.timer?.invalidate()
		}
		Self.timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false, block: { timer in
			SpeechSynthesizer.shared.stopMonitoring()
		})
	}
	

	override func start() {
		debugLog()
		startSpeechSynthesizer()
	}

	override func end() {
		debugLog()
		stopSpeechSynthesizer()
	}
	
	static var buttonLabel: String? {
		return "Edit Memory…"
	}

	static func buttonAction() {
		let fileManager = FileManager.default

		let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		if let applicationSupportDirectory = urls.first {
			let fileURL = applicationSupportDirectory.appendingPathComponent(Self.storageName, conformingTo: .plainText)
			let filePath = fileURL.path
			if fileManager.fileExists(atPath: filePath) {
				NSWorkspace.shared.open(fileURL)
			}
			else {
				let alert = NSAlert()
				alert.messageText = "Memory Not Loaded"
				alert.informativeText = "M.I.T.T. storage has not been initialized.\n\nPlease move your mouse under the notch to install memory."
				alert.runModal()
			}
		}
	}

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
		
		startSpeechSynthesizer()
		
		CATransaction.begin()
		CATransaction.setCompletionBlock {
			let speechSynthesizer = SpeechSynthesizer.shared
			if !speechSynthesizer.isSpeaking {
				let text = self.mittStorage[Self.currentStorageIndex]
				speechSynthesizer.speak(text)
				Self.currentStorageIndex += 1
				if Self.currentStorageIndex >= self.mittStorage.count {
					Self.currentStorageIndex = 0
				}
			}
		}
		
		resetLedLayers(leftIndex: 0, rightIndex: 11, offImage: greenOffImage)
		resetLedLayers(leftIndex: 1, rightIndex: 10, offImage: yellowOffImage)
		resetLedLayers(leftIndex: 2, rightIndex: 9, offImage: orangeOffImage)
		resetLedLayers(leftIndex: 3, rightIndex: 8, offImage: redOffImage)
		resetLedLayers(leftIndex: 4, rightIndex: 7, offImage: purpleOffImage)
		resetLedLayers(leftIndex: 5, rightIndex: 6, offImage: blueOffImage)

		backgroundLayer.position = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.maxY)
		
		let fromPosition: CGPoint
		if let position = backgroundLayer.presentation()?.position {
			fromPosition = position
		}
		else {
			fromPosition = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.minY - backgroundLayer.bounds.height)
		}
		
		let animation = CABasicAnimation(keyPath: "position")
		animation.fromValue = fromPosition
		animation.toValue = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.maxY)
		animation.duration = 0.25
		animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		animation.fillMode = .forwards
		backgroundLayer.add(animation, forKey: "position")
		
		CATransaction.commit()
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
		
		stopSpeechSynthesizer()
		
		CATransaction.begin()
		
		backgroundLayer.position = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.minY - backgroundLayer.bounds.height)
		
		let fromPosition: CGPoint
		if let position = backgroundLayer.presentation()?.position {
			fromPosition = position
		}
		else {
			fromPosition = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.maxY)
		}
		
		let animation = CABasicAnimation(keyPath: "position")
		animation.fromValue = fromPosition
		animation.toValue = CGPoint(x: backgroundLayer.position.x, y: parentLayer.bounds.minY - backgroundLayer.bounds.height)
		animation.duration = 0.25
		animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
		animation.fillMode = .forwards
		backgroundLayer.add(animation, forKey: "position")
		
		CATransaction.commit()
	}

}
