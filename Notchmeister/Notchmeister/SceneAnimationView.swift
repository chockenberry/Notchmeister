//
//  SceneAnimationView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

import SceneKit

class SceneAnimationView: SCNView {
	
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
	
	override init(frame: NSRect, options: [String : Any]? = nil) {
		debugLog()
		super.init(frame: frame, options: options)
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
