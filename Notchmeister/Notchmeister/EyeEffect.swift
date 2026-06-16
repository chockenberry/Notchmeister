//
//  EyeEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 6/14/26.
//

import AppKit

class EyeEffect: NotchEffect {
	
	var leftEyeLayer: CAShapeLayer
	var rightEyeLayer: CAShapeLayer
	var backgroundLayer: CAShapeLayer
	
	var eyesOpen = false
	var isExiting = false
	var isEntered = false

	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		let dimension = parentLayer.bounds.size.height - 4
		self.leftEyeLayer = Self.eyeLayer(dimension: dimension)
		self.rightEyeLayer = Self.eyeLayer(dimension: dimension)
		self.backgroundLayer = CAShapeLayer()
		
		super.init(with: parentLayer, in: parentView, of: parentWindow)

		configureSublayers()
	}
	
	private static func eyeLayer(dimension: CGFloat) -> CAShapeLayer {
		let layer = CAShapeLayer()
		let size = CGSize(width: dimension, height: dimension)
		let path = NSBezierPath.init(ovalIn: NSRect(origin: .zero, size: size))

		layer.path = path.cgPath
		layer.bounds.size = size

		let rotationLayer = CALayer()
		rotationLayer.bounds = layer.bounds
		rotationLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
		
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
			layer.fillColor = NSColor.systemRed.cgColor
			pupilLayer.fillColor = NSColor.systemBlue.cgColor
			rotationLayer.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.75).cgColor
		}
		else {
			layer.fillColor = NSColor(named: "eyeEffect-iris")?.cgColor ?? NSColor.white.cgColor
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

			transformScale(layer: leftEyeLayer, isLeft: true, closed: true)
			transformScale(layer: rightEyeLayer, isLeft: false, closed: true)

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

	private func transformRotate(layer: CALayer, point: CGPoint, layerPoint: CGPoint, closed: Bool = false) {
		let anglePoint = CGPoint(x: layerPoint.x - point.x, y: layerPoint.y - point.y)
		let angle = atan2(anglePoint.y, anglePoint.x)
		if let sublayer = layer.sublayers?.first {
			let affineTransform = CGAffineTransform(rotationAngle: angle)
			sublayer.setAffineTransform(affineTransform)
		}
		
		if closed {
			let affineTransform = CGAffineTransform(scaleX: 1, y: 0)
			layer.setAffineTransform(affineTransform)
		}
		else {
			let affineTransform = CGAffineTransform(scaleX: 1, y: 1)
			layer.setAffineTransform(affineTransform)
		}
	}
		
	private func transformScale(layer: CALayer, isLeft: Bool, closed: Bool) {
		if let sublayer = layer.sublayers?.first {
			let affineTransform = CGAffineTransform(rotationAngle: isLeft ? .pi : 0)
			sublayer.setAffineTransform(affineTransform)
		}
		
		if closed {
			let affineTransform = CGAffineTransform(scaleX: 1, y: 0)
			layer.setAffineTransform(affineTransform)
		}
		else {
			let affineTransform = CGAffineTransform(scaleX: 1, y: 1)
			layer.setAffineTransform(affineTransform)
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
			
			transformScale(layer: leftEyeLayer, isLeft: true, closed: true)
			transformScale(layer: rightEyeLayer, isLeft: false, closed: true)
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
			self.backgroundLayer.path = endPath.cgPath
			debugLog("ANIMATION BACKGROUND: extended")
			
			CATransaction.withActionsDisabled {
				self.leftEyeLayer.opacity = 1
				self.rightEyeLayer.opacity = 1
			}
			
			CATransaction.withChange(duration: self.openCloseDuration) {
				debugLog("ANIMATION EYES: opening")
				self.transformRotate(layer: self.leftEyeLayer, point: point, layerPoint: leftPoint, closed: false)
				self.transformRotate(layer: self.rightEyeLayer, point: point, layerPoint: rightPoint, closed: false)
			} completion: {
				debugLog("ANIMATION EYES: open")
				self.eyesOpen = true
			}
		}
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard isEntered else { return }
		guard let parentLayer = parentLayer else { return }

		let diameter = parentLayer.bounds.size.height
		let radius = diameter / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - radius, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + radius, y: parentLayer.bounds.midY)

		if eyesOpen {
			CATransaction.withChange(duration: movementDuration) {
				transformRotate(layer: leftEyeLayer, point: point, layerPoint: leftPoint, closed: false)
				transformRotate(layer: rightEyeLayer, point: point, layerPoint: rightPoint, closed: false)
			}
		}
	}

	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard !isExiting else { debugLog("GUARD !isExiting: \(ObjectIdentifier(self))"); return }
		guard isEntered else { debugLog("GUARD isEntered: \(ObjectIdentifier(self))"); return }
		guard let parentLayer = parentLayer else { return }
		debugLog(": \(ObjectIdentifier(self))")

		debugLog("ANIMATION EXIT: yes")
		isExiting = true
		
		let diameter = parentLayer.bounds.size.height
		let radius = diameter / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - radius, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + radius, y: parentLayer.bounds.midY)

		let startBounds = parentLayer.bounds.insetBy(dx: -diameter, dy: 0)
		let endBounds = parentLayer.bounds

		let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: radius, yRadius: radius)
		let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: radius, yRadius: radius)

		CATransaction.withActionsDisabled {
			//leftEyeLayer.opacity = 1
			//rightEyeLayer.opacity = 1

			backgroundLayer.path = startPath.cgPath
			backgroundLayer.opacity = 1
		}

		CATransaction.withChange(duration: self.openCloseDuration) {
			self.transformRotate(layer: self.leftEyeLayer, point: point, layerPoint: leftPoint, closed: true)
			self.transformRotate(layer: self.rightEyeLayer, point: point, layerPoint: rightPoint, closed: true)
			debugLog("ANIMATION EYES: closing")
		} completion: {
			debugLog("ANIMATION EYES: closed")
			CATransaction.withActionsDisabled {
				self.leftEyeLayer.opacity = 0
				self.rightEyeLayer.opacity = 0
				self.backgroundLayer.opacity = 1
			}
			
			self.eyesOpen = false
			
			CATransaction.withChange(duration: self.enterExitDuration) {
				let animation = CABasicAnimation(keyPath: "path")
				animation.fromValue = startPath.cgPath
				animation.toValue = endPath.cgPath
				animation.timingFunction = CAMediaTimingFunction(name: .easeIn)

				self.backgroundLayer.path = endPath.cgPath
				self.backgroundLayer.add(animation, forKey: "animatePath")
				debugLog("ANIMATION BACKGROUND: contracting")
			} completion: {
				self.backgroundLayer.path = endPath.cgPath
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

