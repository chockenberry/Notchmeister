//
//  DiceView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

class DiceView: NSImageView {
	
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
		
	override init(frame frameRect: NSRect) {
		debugLog()
		super.init(frame: frameRect)
	}
	
	/*
	override func draw(_ dirtyRect: NSRect) {
		debugLog()
		NSColor.clear.set()
		dirtyRect.fill()

		let path = NSBezierPath(ovalIn: dirtyRect)
		NSColor.systemPurple.setFill()
		path.fill()
	}
	 */
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		debugLog()
		return true
	}
	
	override func mouseDown(with event: NSEvent) {
		debugLog()
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		debugLog("point = \(point)")
		return super.hitTest(point)
	}
	
}
