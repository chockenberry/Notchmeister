//
//  SceneView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

class SceneView: NSView {

	override func draw(_ dirtyRect: NSRect) {
		if Defaults.shouldDebugDrawing {
			NSColor.systemYellow.withAlphaComponent(0.5).set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()

	}

}
