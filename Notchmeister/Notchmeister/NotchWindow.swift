//
// Created by cparrish on 10/28/2021
//

import Cocoa

import CoreGraphics

class NotchWindow: NSWindow {

	required init?(screen: NSScreen, padding: CGFloat) {
		guard let notchRect = screen.notchRect else { return nil }
        
		let contentRect = CGRect(x: notchRect.origin.x - padding, y: notchRect.origin.y - padding, width: notchRect.width + (padding * 2), height: notchRect.height + padding)
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        
		// NOTE: In theory, we should be able to create a window above the cursor. In practice, this doesn't work.
		// More info: https://jameshfisher.com/2020/08/03/what-is-the-order-of-nswindow-levels/
		//self.level = NSWindow.Level.init(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
		//self.level = .screenSaver
		self.level = .popUpMenu // NOTE: I think this is probably best - keeps the window under a screensaver.
        self.hidesOnDeactivate = false
        self.canHide = false
        self.isMovable = false
        self.isOpaque = false
        self.hasShadow = false
		// TODO: .transient works well for fake notch (so it goes away with Exposé), .stationary is better with a real notch (stays put with Exposé)
        self.collectionBehavior = [.transient, .canJoinAllSpaces]
		self.acceptsMouseMovedEvents = true
		
        if Defaults.shouldDebugDrawing {
			self.backgroundColor = .systemPurple
		}
		else {
			self.backgroundColor = .clear
		}
    }

}
