//
//  NotchEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/6/21.
//

import AppKit

// NOTE: Maybe a protocol is the right thing to do here, or maybe just let subclasses override methods.
// I don't really have an opinion about this yet, but I'm sure that day will come after we make a few
// of these. I suspect that the terrible name is an indication that we won't need it.

protocol NotchEffectable { // yeah, this is a terrible name
	
	init (with parentLayer: CALayer, in parentView: NSView)

}

class NotchEffect: NotchEffectable {
	
	private(set) weak var parentLayer: CALayer?
	private(set) weak var parentView: NSView?

	required init (with parentLayer: CALayer, in parentView: NSView) {
		self.parentLayer = parentLayer
		self.parentView = parentView
	}
	
	func start() {
		// override to perform work at the point when the effect is active (because it's moving to a superview)
	}

	func end() {
		// override to perform work at the point when the effect becomes inactive
	}

	// NOTE: The point parameter is relative to upper-left origin of notch. The second parameter indicates if
	// the point is underneath the notch.
	
	func mouseEntered(at point: CGPoint, underNotch: Bool) {
		// override to perform work when the mouse enters the effect layer
	}

	func mouseMoved(at point: CGPoint, underNotch: Bool) {
		// override to perform work when the mouse moves in the effect layer
	}

	func mouseExited(at point: CGPoint, underNotch: Bool) {
		// override to perform work when the mouse leaves the effect layer
	}

	func maxEdgeDistance() -> CGFloat {
		guard let parentLayer = parentLayer else {
			return .leastNormalMagnitude
		}
		
		return parentLayer.bounds.height
	}
	
	func edgeDistance(at point: CGPoint) -> CGFloat {
		// distance of point from edge of the notch: negative is outside, positive is inside
		
		guard let parentLayer = parentLayer else {
			return .greatestFiniteMagnitude
		}

		let notchBounds = parentLayer.bounds
		
		// NOTE: This is an approximation that doesn't take the corner radii into account. So far, the effects haven't
		// needed a precise distance.
		let xDelta: CGFloat
		if point.x < notchBounds.midX {
			xDelta = point.x - notchBounds.minX
		}
		else {
			xDelta = notchBounds.maxX - point.x
		}
		let yDelta = notchBounds.maxY - point.y
		return min(xDelta, yDelta)
	}
}

