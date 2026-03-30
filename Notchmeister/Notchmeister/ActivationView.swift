//
//  ActivationView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 12/23/21.
//

import AppKit

class ActivationView: NSView {

	override func draw(_ dirtyRect: NSRect) {
		debugLog()
		if Defaults.shouldDebugDrawing {
			NSColor.systemGreen.withAlphaComponent(0.5).set()
		}
		else {
			NSColor.clear.set()
		}
		dirtyRect.fill()

		let drawControlPanel = NSScreen.hasNotchedScreen && !Defaults.shouldHideControlPanel

		if drawControlPanel {
			let notchWidth = bounds.width - (NotchWindow.activationPadding * 2)
			let smallMinimumWidth: CGFloat = 137 + (.notchLowerRadius * 2)
			let largeMinimumWidth: CGFloat = 192 + (.notchLowerRadius * 2)
			if notchWidth > smallMinimumWidth {
				// NOTE: The machdep.cpu.brand_string sysctl is used to check for "Apple M2" or "Apple M1"
				// https://cpufun.substack.com/p/more-m1-fun-hardware-information
#if DEBUG && true
				let cpuBrand = "Apple M2"
#else
				let cpuBrand = cpuBrand()
#endif
				let brandOffset: CGPoint
				let imageName: String
#if false
				if cpuBrand.hasPrefix("Apple M3") {
					imageName = notchWidth < largeMinimumWidth ? "m3-controlpanel-small" : "m3-controlpanel"
				}
				else if cpuBrand.hasPrefix("Apple M2") {
					imageName = notchWidth < largeMinimumWidth ? "m2-controlpanel-small" : "m2-controlpanel"
				}
				else {
					imageName = notchWidth < largeMinimumWidth ? "m1-controlpanel-small" : "m1-controlpanel"
				}
#else
#if DEBUG && true
				brandOffset = CGPoint(x: 40, y: 14)
				imageName = "controlpanel-small"
#else
				imageName = notchWidth < largeMinimumWidth ? "controlpanel-small" : "controlpanel"
#endif
				var totalWidth: CGFloat = 0
				
				let prefix = "Apple M"
				if cpuBrand.hasPrefix(prefix) {
					//let iteration = cpuBrand.substring(from: prefix.endIndex)
					let iteration = cpuBrand[prefix.endIndex..<cpuBrand.endIndex]
					debugLog("iteration = \(iteration)")
					if let mImage = NSImage(named: "M") {
						debugLog("mImage.size = \(mImage.size)")
						totalWidth += mImage.size.width
					}
					for number in iteration {
						debugLog("number = \(number)")
						if let numberImage = NSImage(named: String(number)) {
							debugLog("numberImage.size = \(numberImage.size)")
							totalWidth += numberImage.size.width + 0.5
						}
					}
				}
				debugLog("totalWidth = \(totalWidth)")

#endif
				if let image = NSImage(named: imageName) {
					let drawRect = CGRect(origin: CGPoint(x: bounds.midX - image.size.width / 2, y: bounds.minY + NotchWindow.activationPadding + 1), size: image.size)
					image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1)
										
					if let mImage = NSImage(named: "M") {
						let origin = CGPoint(
							x: ceil(drawRect.origin.x + brandOffset.x - (totalWidth / 2.0)), // - (mImage.size.width / 2.0)),
							y: ceil(drawRect.origin.y + brandOffset.y - (mImage.size.height / 2.0)))
						let size = mImage.size
						let mRect = CGRect(origin: origin, size: size)
						mImage.draw(in: mRect, from: .zero, operation: .sourceOver, fraction: 1)
					}

					let iteration = cpuBrand[prefix.endIndex..<cpuBrand.endIndex]
					for number in iteration {
						debugLog("number = \(number)")
						if let numberImage = NSImage(named: String(number)) {
							let origin = CGPoint(
								x: floor(drawRect.origin.x + brandOffset.x - (totalWidth / 2.0) - (numberImage.size.width / 2.0)),
								y: floor(drawRect.origin.y + brandOffset.y - (numberImage.size.height / 2.0)))
							let size = numberImage.size
							let numberRect = CGRect(origin: origin, size: size)
							//numberImage.draw(in: numberRect, from: .zero, operation: .sourceOver, fraction: 1)
						}
					}

#if DEBUG && true
					do {
						let origin = CGPoint(
							x: ceil(drawRect.origin.x + brandOffset.x - (totalWidth / 2.0)), // - (mImage.size.width / 2.0)),
							y: ceil(drawRect.origin.y + brandOffset.y))
						let size = CGSize(width: totalWidth, height: 0.5)
						let fillRect = CGRect(origin: origin, size: size)

						NSColor.systemGreen.setFill()
						fillRect.fill()
					}

					do {
						let origin = CGPoint(
							x: floor(drawRect.origin.x + brandOffset.x), // - (mImage.size.width / 2.0)),
							y: floor(drawRect.origin.y + brandOffset.y))
						let size = CGSize(width: 0.5, height: 0.5)
						let fillRect = CGRect(origin: origin, size: size)

						NSColor.systemRed.setFill()
						fillRect.fill()
					}
#endif

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
		NSApplication.shared.activate(ignoringOtherApps: true)
		if let window = NSApplication.shared.windows.first {
			window.makeKeyAndOrderFront(self)
			debugLog("activated main window")
		}
	}

}
