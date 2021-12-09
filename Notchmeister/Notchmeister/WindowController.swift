//
//  WindowController.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 12/9/21.
//

import AppKit

class WindowController: NSWindowController {

	override func windowDidLoad() {
		super.windowDidLoad()

		setupWindowAutosave()
	}

	private func setupWindowAutosave() {
		guard let window = window else { return }
		
		// center the window the first time it's loaded (setting this in the NIB doesn't work with auto layout)
		let name = "__Notchmeister"
		if window.setFrameUsingName(name) == false {
			window.center()
		}
		window.setFrameAutosaveName(name)
	}

}
