//
//  CoreGraphics.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/11/21.
//

import CoreGraphics

extension CGPoint {

	static func +(point1: CGPoint, point2: CGPoint) -> CGPoint {
		return CGPoint(x: point1.x + point2.x, y: point1.y + point2.y)
	}

	static func -(point1: CGPoint, point2: CGPoint) -> CGPoint {
		return CGPoint(x: point1.x - point2.x, y: point1.y - point2.y)
	}

}

extension CGSize {
	
	static func *(size: CGSize, scale: CGFloat) -> CGSize {
		return CGSize(width: size.width * scale, height: size.height * scale)
	}

}
