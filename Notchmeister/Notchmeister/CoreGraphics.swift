//
//  CoreGraphics.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/11/21.
//

import AppKit

extension CGPoint {

	static func +(pt1: CGPoint, pt2: CGPoint) -> CGPoint {
		return CGPoint(x: pt1.x + pt2.x, y: pt1.y + pt2.y)
	}

	static func -(pt1: CGPoint, pt2: CGPoint) -> CGPoint {
		return CGPoint(x: pt1.x - pt2.x, y: pt1.y - pt2.y)
	}

}
