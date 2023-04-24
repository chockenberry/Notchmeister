//
//  SceneView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

import SceneKit

class SceneView: SCNView {

	override func draw(_ dirtyRect: NSRect) {
		if Defaults.shouldDebugDrawing {
			NSColor.systemYellow.withAlphaComponent(0.5).set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()

	}

	var globalMonitor: Any?

	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
	
	override init(frame: NSRect, options: [String : Any]? = nil) {
		debugLog()
		super.init(frame: frame, options: options)
		
//		globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { event in
//			//debugLog("global event = \(String(describing: event))")
//			if let window = self.window {
//				let windowLocation = window.convertPoint(fromScreen: event.locationInWindow)
//				if let windowEvent = NSEvent.mouseEvent(with: .leftMouseDown, location: windowLocation, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, eventNumber: event.eventNumber, clickCount: event.clickCount, pressure: event.pressure) {
//					self.mouseDown(with: windowEvent)
//				}
//			}
//		}

	}
	
	override init(frame frameRect: NSRect) {
		debugLog()
		super.init(frame: frameRect)
	}
	
	deinit {
		if let globalMonitor {
			NSEvent.removeMonitor(globalMonitor)
			self.globalMonitor = nil
		}

	}
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		debugLog()
		return true
	}
	
	override func mouseDown(with event: NSEvent) {
		debugLog()
		let hitResults = self.hitTest(event.locationInWindow, options: [:])
		if hitResults.count > 0 {
			let node = hitResults.first!.node
			debugLog("node = \(node)")
			//NSApp.activate(ignoringOtherApps: true)
		}
		else {
		}
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		debugLog("point = \(point)")
		
		if point.x < 150 && point.y < 150 {
			return self
		}
		else {
			return nil
		}
//		let hitResults = self.hitTest(point, options: [:])
//		if hitResults.count > 0 {
//			let node = hitResults.first!.node
//			debugLog("node = \(node)")
//			return self
//			//NSApp.activate(ignoringOtherApps: true)
//		}
//		else {
//			return nil
//		}
	}
	
}
