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
	var eyesExtended = false
	
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

		let pupilLayer = CAShapeLayer()
		let pupilDimension = dimension / 3
		let pupilSize = CGSize(width: pupilDimension, height: pupilDimension)
		let pupilPath = NSBezierPath.init(ovalIn: NSRect(origin: .zero, size: pupilSize))
		pupilLayer.fillColor = NSColor.black.cgColor
		pupilLayer.path = pupilPath.cgPath
		pupilLayer.bounds.size = pupilSize
		
		let offset = dimension / 4
		pupilLayer.position = CGPoint(x: layer.bounds.minX + offset, y: layer.bounds.midY)

		layer.addSublayer(pupilLayer)
		return layer
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		do {
			if Defaults.shouldDebugDrawing {
				leftEyeLayer.fillColor = NSColor.systemGreen.cgColor
				rightEyeLayer.fillColor = NSColor.systemRed.cgColor
			}
			else {
				leftEyeLayer.fillColor = NSColor.white.cgColor
				rightEyeLayer.fillColor = NSColor.white.cgColor
			}
			leftEyeLayer.opacity = 0
			rightEyeLayer.opacity = 0

			let offset = parentLayer.bounds.size.height
			let halfOffset = offset / 2
			
			leftEyeLayer.position = CGPoint(x: parentLayer.bounds.minX - halfOffset, y: parentLayer.bounds.midY)
			rightEyeLayer.position = CGPoint(x: parentLayer.bounds.maxX + halfOffset, y: parentLayer.bounds.midY)

			transformScale(layer: leftEyeLayer, isLeft: true, closed: true)
			transformScale(layer: rightEyeLayer, isLeft: false, closed: true)

			//layer.path = path.cgPath
			//layer.bounds.size = size

//			let backgroundBounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
			let backgroundBounds = parentLayer.bounds
			let backgroundPath = NSBezierPath.init(roundedRect: backgroundBounds, xRadius: halfOffset, yRadius: halfOffset)
			backgroundLayer.path = backgroundPath.cgPath
			
			if Defaults.shouldDebugDrawing {
				backgroundLayer.fillColor = NSColor.systemYellow.cgColor
			}
			else {
				backgroundLayer.fillColor = NSColor.black.cgColor
			}
			//let bounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
			backgroundLayer.anchorPoint = .zero
//			backgroundLayer.position = CGPoint(x: -offset, y: 0)
			backgroundLayer.position = .zero
			backgroundLayer.bounds = backgroundBounds
			backgroundLayer.opacity = 0
			
			parentLayer.addSublayer(backgroundLayer)
			
			parentLayer.addSublayer(leftEyeLayer)
			parentLayer.addSublayer(rightEyeLayer)
		}
	}

	private func transformRotate(layer: CALayer, point: CGPoint, layerPoint: CGPoint, closed: Bool = false) {
		//return
		let anglePoint = CGPoint(x: layerPoint.x - point.x, y: layerPoint.y - point.y)
		let angle = atan2(anglePoint.y, anglePoint.x)
		if closed {
//			let transform = CATransform3DMakeScale(1, 0, 1)
//			let finalTransform = CATransform3DRotate(transform, angle, 0, 0, 1)
			let transform = CATransform3DMakeRotation(angle, 0, 0, 1)
			let finalTransform = CATransform3DScale(transform, 1, 0, 1)
//			let finalTransform = CATransform3DMakeScale(1, 0, 1)
			layer.transform = finalTransform
		}
		else {
			let transform = CATransform3DMakeRotation(angle, 0, 0, 1)
			let finalTransform = CATransform3DScale(transform, 1, 1, 1)
			layer.transform = finalTransform
		}
	}
		
	private func transformScale(layer: CALayer, isLeft: Bool, closed: Bool) {
		if closed {
			let transform = CATransform3DMakeRotation(isLeft ? .pi : 0, 0, 0, 1)
			let finalTransform = CATransform3DScale(transform, 1, 0, 1)
			//let finalTransform = CATransform3DMakeScale(1, 0, 0)
			layer.transform = finalTransform
		}
		else {
			let transform = CATransform3DMakeRotation(isLeft ? .pi : 0, 0, 0, 1)
			let finalTransform = CATransform3DScale(transform, 1, 1, 1)
			//let finalTransform = CATransform3DMakeScale(1, 0, 0)
			layer.transform = finalTransform
		}
	}
	
	let enterExitDuration: TimeInterval = 2
	let openCloseDuration: TimeInterval = 1
	let movementDuration: TimeInterval = 0.1

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let offset = parentLayer.bounds.size.height
		let halfOffset = offset / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - halfOffset, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + halfOffset, y: parentLayer.bounds.midY)

		CATransaction.withActionsDisabled {
			leftEyeLayer.opacity = 1
			rightEyeLayer.opacity = 1
			backgroundLayer.opacity = 1
			
//			transformRotate(layer: leftEyeLayer, point: point, layerPoint: leftPoint, closed: true)
//			transformRotate(layer: rightEyeLayer, point: point, layerPoint: rightPoint, closed: true)
			transformScale(layer: leftEyeLayer, isLeft: true, closed: true)
			transformScale(layer: rightEyeLayer, isLeft: false, closed: true)
			eyesOpen = false
		}

		CATransaction.withChange(duration: enterExitDuration) {
			let startBounds = parentLayer.bounds
			let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: halfOffset, yRadius: halfOffset)
			let endBounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
			let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: halfOffset, yRadius: halfOffset)

			let animation = CABasicAnimation(keyPath: "path")
			animation.fromValue = startPath.cgPath
			animation.toValue = endPath.cgPath
			//animation.duration = enterExitDuration
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				
			backgroundLayer.path = endPath.cgPath
			backgroundLayer.add(animation, forKey: "animatePath")
		} completion: {
			self.eyesExtended = true
			CATransaction.withChange(duration: self.openCloseDuration) {
				//self.transformRotate(layer: self.leftEyeLayer, point: point, layerPoint: leftPoint, closed: false)
				//self.transformRotate(layer: self.rightEyeLayer, point: point, layerPoint: rightPoint, closed: false)
				self.transformScale(layer: self.leftEyeLayer, isLeft: true, closed: false)
				self.transformScale(layer: self.rightEyeLayer, isLeft: false, closed: false)
			} completion: {
				//CATransaction.withActionsDisabled {
					self.transformRotate(layer: self.leftEyeLayer, point: point, layerPoint: leftPoint, closed: false)
					self.transformRotate(layer: self.rightEyeLayer, point: point, layerPoint: rightPoint, closed: false)

				//}
				self.eyesOpen = true
			}

		}
/*
		CATransaction.begin()
		CATransaction.setAnimationDuration(enterExitDuration)

//		transformScale(layer: leftEyeLayer, closed: false)
//		transformScale(layer: rightEyeLayer, closed: false)

//		self.leftEyeLayer.opacity = 1
//		self.rightEyeLayer.opacity = 1


		CATransaction.setCompletionBlock {
			CATransaction.begin()
			CATransaction.setAnimationDuration(self.enterExitDuration)
			self.transformRotate(layer: self.leftEyeLayer, point: point, layerPoint: leftPoint, closed: false)
			self.transformRotate(layer: self.rightEyeLayer, point: point, layerPoint: rightPoint, closed: false)
			CATransaction.commit()
			
			self.eyesOpen = true
		}
		
		let startBounds = parentLayer.bounds
		let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: halfOffset, yRadius: halfOffset)
		let endBounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
		let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: halfOffset, yRadius: halfOffset)

		let animation = CABasicAnimation(keyPath: "path")
		animation.fromValue = startPath.cgPath
		animation.toValue = endPath.cgPath
		//animation.duration = enterExitDuration
		animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			
		backgroundLayer.path = endPath.cgPath
		backgroundLayer.add(animation, forKey: "animatePath")

		CATransaction.commit()
		//		CATransaction.begin()
//		CATransaction.setAnimationDuration(2.0)
//		
//		let backgroundBounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
//		let backgroundPath = NSBezierPath.init(roundedRect: backgroundBounds, xRadius: halfOffset, yRadius: halfOffset)
//		backgroundLayer.path = backgroundPath.cgPath
//		//backgroundLayer.position = CGPoint(x: -offset, y: 0)
//		
//		CATransaction.commit()
*/
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let offset: CGFloat = parentLayer.bounds.size.height / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - offset, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + offset, y: parentLayer.bounds.midY)

		if eyesOpen {
		
			CATransaction.withChange(duration: movementDuration) {
				transformRotate(layer: leftEyeLayer, point: point, layerPoint: leftPoint, closed: false)
				transformRotate(layer: rightEyeLayer, point: point, layerPoint: rightPoint, closed: false)
			}
//		CATransaction.begin()
//		CATransaction.setAnimationDuration(movementDuration)
////		let closed = eyesClosed
////			CATransaction.withActionsDisabled {
////			}
//		CATransaction.commit()
		}
	}

	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let offset = parentLayer.bounds.size.height
		let halfOffset = offset / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - halfOffset, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + halfOffset, y: parentLayer.bounds.midY)

		CATransaction.withActionsDisabled {
			transformScale(layer: leftEyeLayer, isLeft: true, closed: false)
			transformScale(layer: rightEyeLayer, isLeft: false, closed: false)
		}

		CATransaction.withChange(duration: self.openCloseDuration) {
			//self.transformRotate(layer: self.leftEyeLayer, point: point, layerPoint: leftPoint, closed: false)
			//self.transformRotate(layer: self.rightEyeLayer, point: point, layerPoint: rightPoint, closed: false)
			self.transformScale(layer: self.leftEyeLayer, isLeft: true, closed: true)
			self.transformScale(layer: self.rightEyeLayer, isLeft: false, closed: true)
		} completion: {
			self.leftEyeLayer.opacity = 0
			self.rightEyeLayer.opacity = 0
			self.eyesOpen = false
			CATransaction.withChange(duration: self.enterExitDuration) {
				let startBounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
				let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: halfOffset, yRadius: halfOffset)
				let endBounds = parentLayer.bounds
				let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: halfOffset, yRadius: halfOffset)

				let animation = CABasicAnimation(keyPath: "path")
				animation.fromValue = startPath.cgPath
				animation.toValue = endPath.cgPath
				//animation.duration = self.enterExitDuration
				animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
					
				self.backgroundLayer.path = endPath.cgPath
				self.backgroundLayer.add(animation, forKey: "animatePath")
			} completion: {
				self.eyesExtended = false
				CATransaction.withActionsDisabled {
					self.backgroundLayer.opacity = 0
				}
			}
		}

		/*
		CATransaction.withActionsDisabled {
			leftEyeLayer.opacity = 0
			rightEyeLayer.opacity = 0
			//backgroundLayer.opacity = 0

//			transformRotate(layer: leftEyeLayer, point: point, layerPoint: leftPoint, closed: true)
//			transformRotate(layer: rightEyeLayer, point: point, layerPoint: rightPoint, closed: true)
			transformScale(layer: leftEyeLayer, isLeft: true, closed: true)
			transformScale(layer: rightEyeLayer, isLeft: false, closed: true)
			eyesOpen = false
		}

		CATransaction.withChange(duration: enterExitDuration) {
			let startBounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
			let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: halfOffset, yRadius: halfOffset)
			let endBounds = parentLayer.bounds
			let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: halfOffset, yRadius: halfOffset)

			let animation = CABasicAnimation(keyPath: "path")
			animation.fromValue = startPath.cgPath
			animation.toValue = endPath.cgPath
			//animation.duration = self.enterExitDuration
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				
			self.backgroundLayer.path = endPath.cgPath
			self.backgroundLayer.add(animation, forKey: "animatePath")
		} completion: {
			CATransaction.withActionsDisabled {
				self.backgroundLayer.opacity = 0
				self.eyesExtended = false
			}
		}
*/
		
		/*
		CATransaction.begin()
		CATransaction.setAnimationDuration(enterExitDuration)
		
//		leftEyeLayer.opacity = 0
//		rightEyeLayer.opacity = 0
//
//		let transform = CATransform3DMakeScale(1, 0, 1)
//		leftEyeLayer.transform = transform
//		rightEyeLayer.transform = transform

		CATransaction.setCompletionBlock {
			CATransaction.withActionsDisabled {
				self.backgroundLayer.opacity = 0
			}
		}
		
//		CATransaction.setCompletionBlock {
//			CATransaction.begin()
//			CATransaction.setAnimationDuration(2.0)

			let startBounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
			let startPath = NSBezierPath.init(roundedRect: startBounds, xRadius: halfOffset, yRadius: halfOffset)
			let endBounds = parentLayer.bounds
			let endPath = NSBezierPath.init(roundedRect: endBounds, xRadius: halfOffset, yRadius: halfOffset)

			let animation = CABasicAnimation(keyPath: "path")
			animation.fromValue = startPath.cgPath
			animation.toValue = endPath.cgPath
			//animation.duration = self.enterExitDuration
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				
			self.backgroundLayer.path = endPath.cgPath
			self.backgroundLayer.add(animation, forKey: "animatePath")

//			CATransaction.commit()
//		}

		CATransaction.commit()
		 */
	}

}

