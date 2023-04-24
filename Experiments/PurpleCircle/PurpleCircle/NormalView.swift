//
//  SceneView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

class NormalView: NSView {

	override func draw(_ dirtyRect: NSRect) {
		debugLog()
		NSColor.clear.set()
		dirtyRect.fill()

		let drawRect = NSRect(origin: NSPoint(x: bounds.midX - 95, y: bounds.midY - 95), size: NSSize(width: 190, height: 190))
		let path = NSBezierPath(ovalIn: drawRect)
		NSColor.systemPurple.setFill()
		path.fill()
	}

	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
	
	
	override init(frame frameRect: NSRect) {
		debugLog()
		super.init(frame: frameRect)
	}
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		debugLog()
		return true
	}
	
	override func mouseDown(with event: NSEvent) {
		debugLog()
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		debugLog("point = \(point)")
		return self
	}
	
}
