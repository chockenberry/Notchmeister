//
//  ActivationView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 12/23/21.
//

import AppKit

class ActivationView: NSView {

	override func draw(_ dirtyRect: NSRect) {
		if Defaults.shouldDebugDrawing {
			NSColor.systemGreen.withAlphaComponent(0.5).set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()

		let drawControlPanel = NSScreen.hasNotchedScreen
		
		if drawControlPanel {
			let notchWidth = bounds.width - (NotchWindow.activationPadding * 2)
			let smallMinimumWidth: CGFloat = 137 + (.notchLowerRadius * 2)
			let largeMinimumWidth: CGFloat = 192 + (.notchLowerRadius * 2)
			if notchWidth > smallMinimumWidth {
				// NOTE: The machdep.cpu.brand_string sysctl is used to check for "Apple M2" or "Apple M1"
				// https://cpufun.substack.com/p/more-m1-fun-hardware-information
				let imageName: String
				if cpuBrand() == "Apple M2" {
					imageName = notchWidth < largeMinimumWidth ? "m2-controlpanel-small" : "m2-controlpanel"
				}
				else {
					imageName = notchWidth < largeMinimumWidth ? "m1-controlpanel-small" : "m1-controlpanel"
				}
				if let image = NSImage(named: imageName) {
					let drawRect = CGRect(origin: CGPoint(x: bounds.midX - image.size.width / 2, y: bounds.minY + NotchWindow.activationPadding + 1), size: image.size)
					image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1)
				}
			}
		}
	}
	
	private func cpuBrand() -> String {
		var size = 0
		sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
		var brand = [CChar](repeating: 0,  count: size)
		sysctlbyname("machdep.cpu.brand_string", &brand, &size, nil, 0)
		return String(cString: brand)
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
	}
	

}
