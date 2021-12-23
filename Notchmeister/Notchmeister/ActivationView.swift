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
	}

/*
	//MARK: - NSResponder

	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return false
	}
	
	override func mouseDown(with event: NSEvent) {
#if false
		let padding = NotchWindow.padding
		let notchRect = CGRect(x: bounds.origin.x + padding, y: bounds.origin.y + padding, width: bounds.width - (padding * 2), height: bounds.height - padding)
		
		let location = event.locationInWindow
		debugLog("location = \(location)")
		if notchRect.contains(location) {
			if let window = NSApplication.shared.windows.first {
				window.makeKeyAndOrderFront(self)
			}
		}
#else
		let location = event.locationInWindow
		debugLog("location = \(location)")
		if let window = NSApplication.shared.windows.first {
			window.makeKeyAndOrderFront(self)
		}
#endif
	}
 */
	
}
