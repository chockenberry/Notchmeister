//
//  NotchView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import AppKit

class NotchView: NSView {

	var trackingArea: NSTrackingArea?
	var mouseInView: Bool = false
	
	var sublayer: CALayer?
	
	override var isFlipped: Bool {
		get {
			// things are easier if the view and layer origins are in the upper left corner
			return true
		}
	}

	override func viewDidMoveToSuperview() {
		if self.superview != nil {
			// create a tracking area for mouse movements
			let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .mouseMoved]
			let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
			self.trackingArea = trackingArea
			addTrackingArea(trackingArea)
			
			// create a layer hosting view
			wantsLayer = true
			layer?.masksToBounds = false
			if DEBUG_DRAWING {
				self.layer?.backgroundColor = NSColor.systemRed.cgColor
			}
			else {
				self.layer?.backgroundColor = NSColor.black.cgColor
			}
			
			// create a sublayer that will follow mouse movements
			sublayer = CALayer()
			if let sublayer = sublayer {
				let dimension: CGFloat = 20
				sublayer.bounds = CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension))
				sublayer.cornerRadius = dimension / 2
				sublayer.masksToBounds = false
				if DEBUG_DRAWING {
					sublayer.backgroundColor = NSColor.yellow.cgColor
				}
				else {
					sublayer.backgroundColor = NSColor.white.cgColor
				}
				sublayer.position = .zero
				sublayer.opacity = 0
				
				layer?.addSublayer(sublayer)
			}
		}
		else {
			sublayer?.removeFromSuperlayer()
			sublayer = nil
			
			if let trackingArea = trackingArea {
				removeTrackingArea(trackingArea)
				self.trackingArea = nil
			}
		}
	}
	
	override func mouseEntered(with event: NSEvent) {
		debugLog()
		mouseInView = true
		self.sublayer?.opacity = 1
	}
	
	override func mouseMoved(with event: NSEvent) {
		if mouseInView {
			let locationInWindow = event.locationInWindow
			let locationInView = self.convert(locationInWindow, from: nil)
			debugLog("point = \(locationInView)")
			CATransaction.withActionsDisabled {
				self.sublayer?.position = locationInView
			}
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		debugLog()
		mouseInView = false
		self.sublayer?.opacity = 0
	}
	
}
