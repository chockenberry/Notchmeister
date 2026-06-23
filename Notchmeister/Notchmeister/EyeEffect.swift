//
//  EyeEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 6/14/26.
//

import AppKit

class EyeEffect: NotchEffect {
	
	var leftEyeLayer: CALayer
	var rightEyeLayer: CALayer
	var backgroundLayer: CAShapeLayer
	
	var isExiting = false
	var isEntered = false

	var blinkTimer: Timer?
	
	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		let dimension = parentLayer.bounds.size.height - 4
		self.leftEyeLayer = Self.eyeLayer(dimension: dimension)
		self.rightEyeLayer = Self.eyeLayer(dimension: dimension)
		self.backgroundLayer = CAShapeLayer()
		
		super.init(with: parentLayer, in: parentView, of: parentWindow)

		configureSublayers()
	}
	
	private static func eyeLayer(dimension: CGFloat) -> CALayer {
		let layer = CALayer()
		let size = CGSize(width: dimension, height: dimension)

		layer.bounds.size = size
		
		let rotationLayer = CAGradientLayer()
		rotationLayer.bounds = layer.bounds
		rotationLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
		rotationLayer.cornerRadius = size.height / 2
		rotationLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
		rotationLayer.endPoint = CGPoint(x: -0.5, y: 1.25)
		rotationLayer.type = .radial

		let pupilLayer = CAShapeLayer()
		let pupilDimension = dimension / 3
		let pupilSize = CGSize(width: pupilDimension, height: pupilDimension)
		let pupilPath = NSBezierPath.init(ovalIn: NSRect(origin: .zero, size: pupilSize))
		pupilLayer.path = pupilPath.cgPath
		pupilLayer.bounds.size = pupilSize
		
		let offset = dimension / 4
		pupilLayer.position = CGPoint(x: layer.bounds.minX + offset, y: layer.bounds.midY)

		rotationLayer.addSublayer(pupilLayer)
		
		layer.addSublayer(rotationLayer)

		if Defaults.shouldDebugDrawing {
			layer.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.25).cgColor
			let innerColor = NSColor.systemOrange.cgColor
			let outerColor = NSColor.systemPurple.cgColor
			rotationLayer.colors = [innerColor, outerColor]
			pupilLayer.fillColor = NSColor.systemBlue.cgColor
		}
		else {
			layer.backgroundColor = NSColor.clear.cgColor
			let innerColor = NSColor(named: "eyeEffect-iris-inner")?.cgColor ?? NSColor.white.cgColor
			let outerColor = NSColor(named: "eyeEffect-iris-outer")?.cgColor ?? NSColor.gray.cgColor
			rotationLayer.colors = [innerColor, outerColor]
			pupilLayer.fillColor =  NSColor(named: "eyeEffect-pupil")?.cgColor ?? NSColor.black.cgColor
		}
		
		return layer
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		do {
			leftEyeLayer.opacity = 0
			rightEyeLayer.opacity = 0

			let diameter = parentLayer.bounds.size.height
			let radius = diameter / 2
			
			leftEyeLayer.position = CGPoint(x: parentLayer.bounds.minX - radius, y: parentLayer.bounds.midY)
			rightEyeLayer.position = CGPoint(x: parentLayer.bounds.maxX + radius, y: parentLayer.bounds.midY)

			transformScaleEye(layer: leftEyeLayer, isLeft: true, closed: true)
			transformScaleEye(layer: rightEyeLayer, isLeft: false, closed: true)

			let backgroundBounds = parentLayer.bounds
			let backgroundPath = NSBezierPath.init(roundedRect: backgroundBounds, xRadius: radius, yRadius: radius)
			backgroundLayer.path = backgroundPath.cgPath
			
			if Defaults.shouldDebugDrawing {
				backgroundLayer.fillColor = NSColor.systemYellow.cgColor
			}
			else {
				backgroundLayer.fillColor = NSColor.black.cgColor
			}
			backgroundLayer.anchorPoint = .zero
			backgroundLayer.position = .zero
			backgroundLayer.bounds = backgroundBounds
			backgroundLayer.opacity = 0
			
			parentLayer.addSublayer(backgroundLayer)
			
			parentLayer.addSublayer(leftEyeLayer)
			parentLayer.addSublayer(rightEyeLayer)
		}
	}

	private func transformRotateEye(layer: CALayer, point: CGPoint, layerPoint: CGPoint) {
		let anglePoint = CGPoint(x: layerPoint.x - point.x, y: layerPoint.y - point.y)
#if DEBUG && false
		let angle = CGFloat(0)
#else
		let angle = atan2(anglePoint.y, anglePoint.x)
#endif
		if let sublayer = layer.sublayers?.first {
			let affineTransform = CGAffineTransform(rotationAngle: angle)
			sublayer.setAffineTransform(affineTransform)
		}
	}
		
	private func transformScaleEye(layer: CALayer, isLeft: Bool, closed: Bool) {
		if closed {
			let affineTransform = CGAffineTransform(scaleX: 1, y: 0)
			layer.setAffineTransform(affineTransform)
		}
		else {
			let affineTransform = CGAffineTransform(scaleX: 1, y: 1)
			layer.setAffineTransform(affineTransform)
		}
	}
	
	private func blinkEye() {
		let leftSide = Bool.random()
		CATransaction.withChange(duration: self.movementDuration) {
			debugLog("ANIMATION EYES: closing")
			if leftSide {
				self.transformScaleEye(layer: self.leftEyeLayer, isLeft: true, closed: true)
			}
			else {
				self.transformScaleEye(layer: self.rightEyeLayer, isLeft: false, closed: true)
			}
		} completion: {
			CATransaction.withChange(duration: self.movementDuration) {
				debugLog("ANIMATION EYES: opening")
				if leftSide {
					self.transformScaleEye(layer: self.leftEyeLayer, isLeft: true, closed: false)
				}
				else {
					self.transformScaleEye(layer: self.rightEyeLayer, isLeft: false, closed: false)
				}
			} completion: {
				debugLog("ANIMATION EYES: open")
				let blinkDuration = TimeInterval.random(in: 2.0...4.0)
				self.blinkTimer?.invalidate()
				self.blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkDuration, repeats: false) { timer in
					self.blinkEye()
				}
			}
		}

	}
	
	override func end() {
		debugLog()

		if blinkTimer != nil {
			debugLog("ANIMATION END: stopping blink")
			blinkTimer?.invalidate()
			blinkTimer = nil
		}
	}

	let enterExitDuration: TimeInterval = 0.25
	let openCloseDuration: TimeInterval = 0.5
	let movementDuration: TimeInterval = 0.1

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard !isExiting else { debugLog("GUARD !isExiting: \(ObjectIdentifier(self))"); return }
		guard let parentLayer = parentLayer else { return }
		debugLog(": \(ObjectIdentifier(self))")
		
		isEntered = true
		
		let diameter = parentLayer.bounds.size.height
		let radius = diameter / 2
		
		let leftPoint = CGPoint(x: parentLayer.bounds.minX - radius, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + radius, y: parentLayer.bounds.midY)
		
		let startBounds = parentLayer.bounds
		let endBounds = parentLayer.bounds.insetBy(dx: -diameter, dy: 0)
		
		let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: radius, yRadius: radius)
		let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: radius, yRadius: radius)
		
		CATransaction.withActionsDisabled {
			leftEyeLayer.opacity = 0
			rightEyeLayer.opacity = 0
			backgroundLayer.opacity = 1
			
			transformScaleEye(layer: leftEyeLayer, isLeft: true, closed: true)
			transformScaleEye(layer: rightEyeLayer, isLeft: false, closed: true)
			transformRotateEye(layer: self.leftEyeLayer, point: point, layerPoint: leftPoint)
			transformRotateEye(layer: self.rightEyeLayer, point: point, layerPoint: rightPoint)
			debugLog("ANIMATION EYES: closed")
		}
		
		CATransaction.withChange(duration: enterExitDuration) {
			let animation = CABasicAnimation(keyPath: "path")
			animation.fromValue = startPath.cgPath
			animation.toValue = endPath.cgPath
			animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
			
			backgroundLayer.path = endPath.cgPath
			backgroundLayer.add(animation, forKey: "animatePath")
			debugLog("ANIMATION BACKGROUND: extending")
		} completion: {
			debugLog("ANIMATION BACKGROUND: extended")
			
			if !self.isExiting {
				CATransaction.withActionsDisabled {
					self.leftEyeLayer.opacity = 1
					self.rightEyeLayer.opacity = 1
				}
				
				CATransaction.withChange(duration: self.openCloseDuration) {
					debugLog("ANIMATION EYES: opening")
					self.transformScaleEye(layer: self.leftEyeLayer, isLeft: true, closed: false)
					self.transformScaleEye(layer: self.rightEyeLayer, isLeft: false, closed: false)
				} completion: {
					debugLog("ANIMATION EYES: open")
				}
			}
		}
		
		debugLog("ANIMATION EXIT: starting blink")
		let blinkDuration = TimeInterval.random(in: 2.5...5.5)
		blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkDuration, repeats: false) { timer in
			self.blinkEye()
		}
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard isEntered else { return }
		guard let parentLayer = parentLayer else { return }

		let diameter = parentLayer.bounds.size.height
		let radius = diameter / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - radius, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + radius, y: parentLayer.bounds.midY)

		transformRotateEye(layer: leftEyeLayer, point: point, layerPoint: leftPoint)
		transformRotateEye(layer: rightEyeLayer, point: point, layerPoint: rightPoint)
	}

	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard !isExiting else { debugLog("GUARD !isExiting: \(ObjectIdentifier(self))"); return }
		guard isEntered else { debugLog("GUARD isEntered: \(ObjectIdentifier(self))"); return }
		guard let parentLayer = parentLayer else { return }
		debugLog(": \(ObjectIdentifier(self))")

		debugLog("ANIMATION EXIT: yes")
		isExiting = true
		
		if blinkTimer != nil {
			debugLog("ANIMATION EXIT: stopping blink")
			blinkTimer?.invalidate()
			blinkTimer = nil
		}

		let diameter = parentLayer.bounds.size.height
		let radius = diameter / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - radius, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + radius, y: parentLayer.bounds.midY)

		let startBounds = parentLayer.bounds.insetBy(dx: -diameter, dy: 0)
		let endBounds = parentLayer.bounds

		let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: radius, yRadius: radius)
		let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: radius, yRadius: radius)

		CATransaction.withActionsDisabled {
			backgroundLayer.path = startPath.cgPath
			backgroundLayer.opacity = 1
		}

		CATransaction.withChange(duration: self.openCloseDuration) {
			self.transformScaleEye(layer: leftEyeLayer, isLeft: true, closed: true)
			self.transformScaleEye(layer: rightEyeLayer, isLeft: false, closed: true)
			debugLog("ANIMATION EYES: closing")
		} completion: {
			debugLog("ANIMATION EYES: closed")
			CATransaction.withActionsDisabled {
				self.leftEyeLayer.opacity = 0
				self.rightEyeLayer.opacity = 0
				self.backgroundLayer.opacity = 1
			}
			
			CATransaction.withChange(duration: self.enterExitDuration) {
				let animation = CABasicAnimation(keyPath: "path")
				animation.fromValue = startPath.cgPath
				animation.toValue = endPath.cgPath
				animation.timingFunction = CAMediaTimingFunction(name: .easeIn)

				self.backgroundLayer.path = endPath.cgPath
				self.backgroundLayer.add(animation, forKey: "animatePath")
				debugLog("ANIMATION BACKGROUND: contracting")
			} completion: {
				debugLog("ANIMATION BACKGROUND: contracted")
				CATransaction.withActionsDisabled {
					self.leftEyeLayer.opacity = 0
					self.rightEyeLayer.opacity = 0
					self.backgroundLayer.opacity = 0
					self.backgroundLayer.path = endPath.cgPath
				}

				debugLog("ANIMATION EXIT: no")
				self.isExiting = false
				self.isEntered = false
			}
		}
	}

}

