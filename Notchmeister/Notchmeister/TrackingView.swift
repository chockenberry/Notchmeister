//
//  TrackingView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/9/21.
//

import AppKit

class TrackingView: NSView {

	var trackingArea: NSTrackingArea?

	override func draw(_ dirtyRect: NSRect) {
		if Defaults.shouldDebugDrawing {
			NSColor.systemOrange.set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()
	}

	//MARK: - NSTrackingArea

	private func createTrackingArea() {
		if trackingArea == nil {
			// create a tracking area for mouse movements
			let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseEnteredAndExited, .mouseMoved]
			let trackingRect = self.bounds
			let trackingArea = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
			self.trackingArea = trackingArea
			addTrackingArea(trackingArea)
		}
	}
	
	private func destroyTrackingArea() {
		if let trackingArea = trackingArea {
			removeTrackingArea(trackingArea)
			self.trackingArea = nil
		}
	}
	
	
	override func updateTrackingAreas() {
		debugLog()
		
		destroyTrackingArea()
		createTrackingArea()
		
		super.updateTrackingAreas()
	}
	
	//MARK: - NSResponder
	
	override func mouseEntered(with event: NSEvent) {
		debugLog()
		super.mouseEntered(with: event)
		
		/*
		 TODO: Try creating global and local event monitors:
		 
		 NSEvent.addGlobalMonitorForEventsMatchingMask()
		 NSEvent.addLocalMonitorForEventsMatchingMask()
		 
		 Then pass event up to window with NSApp.sendEvent()
		 
		 NSEvent.mouseEvent(with: .mouseMoved, location: <#T##NSPoint#>, modifierFlags: <#T##NSEvent.ModifierFlags#>, timestamp: <#T##TimeInterval#>, windowNumber: <#T##Int#>, context: <#T##NSGraphicsContext?#>, eventNumber: <#T##Int#>, clickCount: <#T##Int#>, pressure: <#T##Float#>)

		 */
	}
	
	override func mouseMoved(with event: NSEvent) {
		debugLog()
		super.mouseMoved(with: event)
	}
	
	override func mouseExited(with event: NSEvent) {
		debugLog()
		super.mouseExited(with: event)
		
		/*
		 TODO: Try destroying global and local event monitors...
		 */
	}

}

