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
#if DEBUG && false
				let cpuBrand = "Apple M4"
#else
				// NOTE: The machdep.cpu.brand_string sysctl is used to check for "Apple M1", "Apple M2", etc.
				// https://cpufun.substack.com/p/more-m1-fun-hardware-information
				let cpuBrand = cpuBrand()
#endif
				
				let brandOffset: CGPoint
				let imageName: String

#if DEBUG && false
				let smallWidth = false
#else
				let smallWidth = notchWidth < largeMinimumWidth
#endif
				if smallWidth {
					brandOffset = CGPoint(x: 40.5, y: 14)
					imageName = "controlpanel-small"
				}
				else {
					brandOffset = CGPoint(x: 95.5, y: 14)
					imageName = "controlpanel"
				}

				var totalWidth: CGFloat = 0
				let drawPadding: CGFloat = 1.0
				
				let prefix = "Apple M"
				if cpuBrand.hasPrefix(prefix) {
					if let mImage = NSImage(named: "M") {
						totalWidth += mImage.size.width
					}
					let numbers = cpuBrand[prefix.endIndex..<cpuBrand.endIndex]
					for number in numbers {
						if let numberImage = NSImage(named: String(number)) {
							totalWidth += numberImage.size.width + drawPadding
						}
					}
				}

				if let image = NSImage(named: imageName) {
					let drawRect = CGRect(origin: CGPoint(x: bounds.midX - image.size.width / 2, y: bounds.minY + NotchWindow.activationPadding + 1), size: image.size)
					image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1)
										
					var drawIndent = -totalWidth / 2.0
					
					if let mImage = NSImage(named: "M") {
						let origin = CGPoint(
							x: drawRect.origin.x + brandOffset.x + pixelClamp(drawIndent), // - (mImage.size.width / 2.0)),
							y: drawRect.origin.y + brandOffset.y - pixelClamp(mImage.size.height / 2.0))
						let size = mImage.size
						let mRect = CGRect(origin: origin, size: size)
						mImage.draw(in: mRect, from: .zero, operation: .sourceOver, fraction: 1)
						
						drawIndent += mImage.size.width + drawPadding
					}

					let numbers = cpuBrand[prefix.endIndex..<cpuBrand.endIndex]
					for number in numbers {
						if let numberImage = NSImage(named: String(number)) {
							let origin = CGPoint(
								x: drawRect.origin.x + brandOffset.x + pixelClamp(drawIndent),
								y: drawRect.origin.y + brandOffset.y - pixelClamp(numberImage.size.height / 2.0))
							let size = numberImage.size
							let numberRect = CGRect(origin: origin, size: size)
							numberImage.draw(in: numberRect, from: .zero, operation: .sourceOver, fraction: 1)

							// NOTE: "1" is the narrowest image at 3×9 pixels, "4" is the widest at 7×9 pixels, others are 6×9 pixels.
							drawIndent += numberImage.size.width + drawPadding
						}
					}

#if DEBUG && false
					do {
						let origin = CGPoint(
							x: drawRect.origin.x + brandOffset.x + pixelClamp(-totalWidth / 2.0),
							y: drawRect.origin.y + brandOffset.y)
						let size = CGSize(width: totalWidth, height: 0.5)
						let fillRect = CGRect(origin: origin, size: size)

						NSColor.systemGreen.setFill()
						fillRect.fill()
					}

					do {
						let origin = CGPoint(
							x: drawRect.origin.x + brandOffset.x,
							y: drawRect.origin.y + brandOffset.y)
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
	
	private func pixelClamp(_ dimension: CGFloat) -> CGFloat {
		// NOTE: A 2x Retina Display is assumed. Every Mac with a notch has one.
		let pixelScale: CGFloat = window?.screen?.backingScaleFactor ?? 2.0
		let result = floor(dimension * pixelScale) / pixelScale
		return result
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
