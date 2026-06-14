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
	var backgroundLayer: CALayer

	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		let dimension = parentLayer.bounds.size.height
		self.leftEyeLayer = Self.eyeLayer(dimension: dimension)
		self.rightEyeLayer = Self.eyeLayer(dimension: dimension)
		self.backgroundLayer = CALayer()
		
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
		
		let offset = pupilDimension / 2
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

			let offset: CGFloat = parentLayer.bounds.size.height / 2

			leftEyeLayer.position = CGPoint(x: parentLayer.bounds.minX - offset, y: parentLayer.bounds.midY)
			rightEyeLayer.position = CGPoint(x: parentLayer.bounds.maxX + offset, y: parentLayer.bounds.midY)

			if Defaults.shouldDebugDrawing {
				backgroundLayer.backgroundColor = NSColor.systemYellow.cgColor
			}
			else {
				backgroundLayer.backgroundColor = NSColor.black.cgColor
			}
			let bounds = parentLayer.bounds.insetBy(dx: -offset, dy: 0)
			backgroundLayer.anchorPoint = .zero
			backgroundLayer.position = CGPoint(x: -offset, y: 0)
			backgroundLayer.bounds = bounds
			backgroundLayer.opacity = 0
			
			parentLayer.addSublayer(backgroundLayer)
			
			parentLayer.addSublayer(leftEyeLayer)
			parentLayer.addSublayer(rightEyeLayer)
		}
	}

	private func transform(layer: CALayer, point: CGPoint, layerPoint: CGPoint) {
		let anglePoint = CGPoint(x: layerPoint.x - point.x, y: layerPoint.y - point.y)
		let angle = atan2(anglePoint.y, anglePoint.x)
		let transform = CATransform3DMakeRotation(angle, 0, 0, 1)
		layer.transform = transform
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		CATransaction.withActionsDisabled {
			leftEyeLayer.opacity = 1
			rightEyeLayer.opacity = 1
			backgroundLayer.opacity = 1
			
			let offset: CGFloat = parentLayer.bounds.size.height / 2
			
			let leftPoint = CGPoint(x: parentLayer.bounds.minX - offset, y: parentLayer.bounds.midY)
			let rightPoint = CGPoint(x: parentLayer.bounds.maxX + offset, y: parentLayer.bounds.midY)
			
			transform(layer: leftEyeLayer, point: point, layerPoint: leftPoint)
			transform(layer: rightEyeLayer, point: point, layerPoint: rightPoint)
		}
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let offset: CGFloat = parentLayer.bounds.size.height / 2

		let leftPoint = CGPoint(x: parentLayer.bounds.minX - offset, y: parentLayer.bounds.midY)
		let rightPoint = CGPoint(x: parentLayer.bounds.maxX + offset, y: parentLayer.bounds.midY)

		CATransaction.begin()
		CATransaction.setAnimationDuration(0.1)
		transform(layer: leftEyeLayer, point: point, layerPoint: leftPoint)
		transform(layer: rightEyeLayer, point: point, layerPoint: rightPoint)
		CATransaction.commit()
	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		CATransaction.withActionsDisabled {
			leftEyeLayer.opacity = 0
			rightEyeLayer.opacity = 0
			backgroundLayer.opacity = 0
		}
	}

}

