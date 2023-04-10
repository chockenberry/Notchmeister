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
			NSColor.systemGreen.set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()

		#if DEBUG
			let drawControlPanel = true
		#else
			let drawControlPanel = NSScreen.hasNotchedScreen
		#endif
		
		if drawControlPanel {
			// TODO: Use machdep.cpu.brand_string to check for "Apple M2" or "Apple M1"
			debugLog("cpuBrand = \(cpuBrand())")
			let notchWidth = bounds.width - (NotchWindow.activationPadding * 2)
			let smallMinimumWidth: CGFloat = 137 + (.notchLowerRadius * 2)
			let largeMinimumWidth: CGFloat = 192 + (.notchLowerRadius * 2)
			if notchWidth > smallMinimumWidth {
				let imageName = notchWidth < largeMinimumWidth ? "controlpanel-small" : "controlpanel"
				if let image = NSImage(named: imageName) {
					let drawRect = CGRect(origin: CGPoint(x: bounds.midX - image.size.width / 2, y: bounds.minY + NotchWindow.activationPadding), size: image.size)
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

}
