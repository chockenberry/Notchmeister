//
//  NotchEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/6/21.
//

import AppKit

// NOTE: Maybe a protocol is the right thing to do here, or maybe just let subclasses override methods.
// I don't really have an opinion about this yet, but I'm sure that day will come after we make a few
// of these.

protocol NotchEffectable { // yeah, this is a terrible name
	
	init (with parentLayer: CALayer)

}

class NotchEffect: NotchEffectable {
	
	private(set) weak var parentLayer: CALayer?
	
	required init (with parentLayer: CALayer) {
		self.parentLayer = parentLayer
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
}

