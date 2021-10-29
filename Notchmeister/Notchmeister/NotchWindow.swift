//
// Created by cparrish on 10/28/2021
//

import Cocoa

extension NSScreen {
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
		
		let fakeNotchSize = NSSize(width:200, height:screenFrame.maxY - visibleFrame.maxY)

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

    required init?(fakeANotch: Bool) {

        // TODO: is the laptop screen always main? probably not
        // could loop over all screens looking for any that report aux areas
        // also may need to watch for display arranement changes?
		
        // NOTE: I'm pretty sure a laptop screen will always be first. Don't want to use
		// main since that returns the screen with keyboard focus. -ch
		guard let screen = NSScreen.screens.first else {
            return nil;
        }
        
        let contentRect: NSRect
        if let notchArea = screen.notchArea {
            contentRect = notchArea
        }
        else if fakeANotch {
            contentRect = screen.fakeNotchArea
        }
        else {
            return nil
        }
        
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        
        //self.level = .screenSaver - 1
		self.level = .popUpMenu // NOTE: I think this is a better guess. -ch
        self.hidesOnDeactivate = false
        self.isMovable = false
        self.isOpaque = false
        self.hasShadow = false
        self.collectionBehavior = [.transient, .canJoinAllSpaces]
		self.acceptsMouseMovedEvents = true
		
		if DEBUG_DRAWING {
			self.backgroundColor = .systemPurple
		}
		else {
			self.backgroundColor = .clear
		}
    }
    
}
