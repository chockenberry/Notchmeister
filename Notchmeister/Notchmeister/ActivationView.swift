//
//  ActivationView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 12/23/21.
//

import AppKit

class ActivationView: NSView {

	override func draw(_ dirtyRect: NSRect) {
		if Defaults.shouldDebugDrawing {
			NSColor.systemGreen.set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()

		if NSScreen.hasNotchedScreen {
			if let image = NSImage(named: "controlpanel") {
				let drawRect = CGRect(origin: CGPoint(x: bounds.midX - image.size.width / 2, y: bounds.minY + NotchWindow.activationPadding + 1), size: image.size)
				image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1)
			}
		}
	}
	
}
