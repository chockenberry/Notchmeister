//
//  ImageView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

class ImageView: NSImageView {

#if false
	var image: NSImage?
	
	override func draw(_ dirtyRect: NSRect) {
		//debugLog()
		NSColor.clear.set()
		dirtyRect.fill()

//		let drawRect = NSRect(origin: NSPoint(x: bounds.midX - 95, y: bounds.midY - 95), size: NSSize(width: 190, height: 190))
//		let path = NSBezierPath(ovalIn: drawRect)
//		NSColor.systemPurple.setFill()
//		path.fill()
		
//		super.draw(dirtyRect)
		let rect = NSRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: 50))
//		image?.draw(in: rect)
		NSColor.systemRed.setFill()
		rect.fill()
	}
#endif
	
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
		return super.hitTest(point)
//		let rect = NSRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: 50))
//		if rect.contains(point) {
//			return self
//		}
//		else {
//			return nil
//		}
	}
	
}
