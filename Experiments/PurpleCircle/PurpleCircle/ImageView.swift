//
//  ImageView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

class ImageView: NSImageView {

	var paths: [NSBezierPath] {
		didSet {
			needsDisplay = true
		}
	}
	
#if true
	//var image: NSImage?
	
	override func draw(_ dirtyRect: NSRect) {
		//debugLog()
		NSColor.clear.set()
		dirtyRect.fill()

//		let drawRect = NSRect(origin: NSPoint(x: bounds.midX - 95, y: bounds.midY - 95), size: NSSize(width: 190, height: 190))
//		let path = NSBezierPath(ovalIn: drawRect)
//		NSColor.systemPurple.setFill()
//		path.fill()
		
//		super.draw(dirtyRect)
//		let rect = NSRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: 50))
//		image?.draw(in: rect)
//		let rect = boundingRect
		
		NSColor.systemRed.setFill()
		for path in paths {
			path.fill()
		}
	}
#endif
	
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
	
	
	override init(frame frameRect: NSRect) {
		debugLog()
		//boundingRect = .zero
		paths = []
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
		if let window {
			var origin = window.frame.origin
			origin.x += 10
			origin.y += 10
			window.setFrameOrigin(origin)
		}
		return super.hitTest(point)
	}
	
}
