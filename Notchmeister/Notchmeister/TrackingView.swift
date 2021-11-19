//
//  TrackingView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/9/21.
//

import AppKit

class TrackingView: NSView {

	var trackingArea: NSTrackingArea?
	
	var globalMonitor: Any?
	var localMonitor: Any?

	override func draw(_ dirtyRect: NSRect) {
		if Defaults.shouldDebugDrawing {
			NSColor.systemOrange.set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()
	}

	deinit {
		disable()
	}
	
	func disable() {
		destroyTrackingArea()
		removeEventMonitors()
	}

	//MARK: - NSTrackingArea

	private func createTrackingArea() {
		if trackingArea == nil {
			// create a tracking area for mouse movements
//			let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseEnteredAndExited, .mouseMoved]
			let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseEnteredAndExited]
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
	
	// NOTE: Tracking mouse movement with NSTrackingArea is unreliable: window ordering complicates things.
	// Both local and global event monitors provides more predictable results, but at a cost of CPU usage (many
	// events must be processed.)
	//
	// To mitigate this, the event monitors are created when entering the tracking area and destroyed when leaving.
	
	private func addEventMonitors() {
		debugLog()
		globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { event in
			//debugLog("global event")
			if let window = self.window {
				let windowLocation = window.convertPoint(fromScreen: event.locationInWindow)
				if let windowEvent = NSEvent.mouseEvent(with: .mouseMoved, location: windowLocation, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, eventNumber: event.eventNumber, clickCount: event.clickCount, pressure: event.pressure) {
					super.mouseMoved(with: windowEvent)
				}
			}
		}
	
		localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
			debugLog("local event, event.window = \(String(describing: event.window)), window = \(String(describing: self.window))")
			if let window = self.window {
				if let eventWindow = event.window {
					// the event happened in another one of our windows
					let screenLocation = eventWindow.convertPoint(toScreen: event.locationInWindow)
					let windowLocation = window.convertPoint(fromScreen: screenLocation)
					
					if let windowEvent = NSEvent.mouseEvent(with: .mouseMoved, location: windowLocation, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, eventNumber: event.eventNumber, clickCount: event.clickCount, pressure: event.pressure) {
						super.mouseMoved(with: windowEvent)
					}
				}
				else {
					// the event happened in this view's parent
					let windowLocation = window.convertPoint(fromScreen: event.locationInWindow)
					if let windowEvent = NSEvent.mouseEvent(with: .mouseMoved, location: windowLocation, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, eventNumber: event.eventNumber, clickCount: event.clickCount, pressure: event.pressure) {
						super.mouseMoved(with: windowEvent)
					}
				}
			}
			else {
				super.mouseMoved(with: event)
			}
			return nil
		}
	}
	
	private func removeEventMonitors() {
		debugLog()
		if let globalMonitor = globalMonitor {
			NSEvent.removeMonitor(globalMonitor)
			self.globalMonitor = nil
		}
		if let localMonitor = localMonitor {
			NSEvent.removeMonitor(localMonitor)
			self.localMonitor = nil
		}
	}
	
	override func mouseEntered(with event: NSEvent) {
		debugLog()
		super.mouseEntered(with: event)
		
		removeEventMonitors()
		addEventMonitors()
	}
	
//	override func mouseMoved(with event: NSEvent) {
//		debugLog()
//		super.mouseMoved(with: event)
//	}
	
	override func mouseExited(with event: NSEvent) {
		debugLog()
		super.mouseExited(with: event)
		
		removeEventMonitors()
	}

}
