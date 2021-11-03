//
// Created by cparrish on 10/28/2021
//

import Cocoa

import CoreGraphics

extension NSScreen {

	static var notchedScreens: [NSScreen] {
		// Always favor physical screens with a notch, but return all screens if we're faking notches.
		if Defaults.shouldFakeNotch {
			return NSScreen.screens
		} else {
			return NSScreen.screens.filter { $0.notchArea != nil }
		}
	}
	
	var notchRect: NSRect? {
		if let notchArea = self.notchArea {
			return notchArea
		}
        else if Defaults.shouldFakeNotch {
			return self.fakeNotchArea
		}
		else {
			return nil
		}
	}
	
    var notchArea: NSRect? {
        guard let topLeft = topLeftSafeArea, let topRight = topRightSafeArea else {
            return nil
        }
        
        let width = topRight.minX - topLeft.maxX
        let height = max(topRight.height, topLeft.height)
        let x = topLeft.maxX
        let y = min(topLeft.minY, topRight.minY)

        return NSRect(x: x, y: y, width: width, height: height)
    }
    
    var fakeNotchArea: NSRect {
		let screenFrame = self.frame
		let visibleFrame = self.visibleFrame
		
		let fakeNotchSize = NSSize(width:220, height:screenFrame.maxY - visibleFrame.maxY)

        let x = self.frame.midX - (fakeNotchSize.width / 2)
        let y = self.frame.maxY - fakeNotchSize.height
        return NSRect(origin:NSPoint(x: x, y: y), size:fakeNotchSize)
    }
    
    var topLeftSafeArea: NSRect? {
        if #available(macOS 12, *) {
            return self.auxiliaryTopLeftArea
        }
        else {
            return nil
        }
    }
    
    var topRightSafeArea: NSRect? {
        if #available(macOS 12, *) {
            return self.auxiliaryTopRightArea
        }
        else {
            return nil
        }
    }
}

class NotchWindow: NSWindow {

	required init?(screen: NSScreen, padding: CGFloat) {
		guard let notchRect = screen.notchRect else { return nil }
        
		let contentRect = CGRect(x: notchRect.origin.x - padding, y: notchRect.origin.y - padding, width: notchRect.width + (padding * 2), height: notchRect.height + padding)
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        
		// NOTE: In theory, we should be able to create a window above the cursor. In practice, this doesn't work.
		// More info: https://jameshfisher.com/2020/08/03/what-is-the-order-of-nswindow-levels/
		//self.level = NSWindow.Level.init(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
		//self.level = .screenSaver
		//self.level = .popUpMenu // NOTE: I think this is probably best - keeps the window under a screensaver.
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
