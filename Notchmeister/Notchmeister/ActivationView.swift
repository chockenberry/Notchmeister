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

		#if DEBUG
			let drawControlPanel = true
		#else
			let drawControlPanel = NSScreen.hasNotchedScreen
		#endif
		
		if drawControlPanel {
			let notchWidth = bounds.width - (NotchWindow.activationPadding * 2)
			let smallMinimumWidth: CGFloat = 137 + (.notchLowerRadius * 2)
			let largeMinimumWidth: CGFloat = 192 + (.notchLowerRadius * 2)
			if notchWidth > smallMinimumWidth {
				let imageName = notchWidth < largeMinimumWidth ? "controlpanel-small" : "controlpanel"
				if let image = NSImage(named: imageName) {
					let drawRect = CGRect(origin: CGPoint(x: bounds.midX - image.size.width / 2, y: bounds.minY + NotchWindow.activationPadding), size: image.size)
					image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1)
				}
			}
		}
	}
	
}
