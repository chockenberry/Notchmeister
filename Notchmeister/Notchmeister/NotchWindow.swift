//
// Created by cparrish on 10/28/2021
//

import Cocoa

import CoreGraphics

class NotchWindow: NSWindow {
    
	var trackingArea: NSTrackingArea?

    var notchView: NotchView?

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
		self.ignoresMouseEvents = true // clicking on the window does not make the app frontmost, tracking area still works
        self.canHide = false
        self.isMovable = false
        self.isOpaque = false
        self.hasShadow = false
		// TODO: .transient works well for fake notch (so it goes away with Exposé), .stationary is better with a real notch (stays put with Exposé)
        self.collectionBehavior = [.transient, .canJoinAllSpaces]
		self.acceptsMouseMovedEvents = true
		
		self.delegate = self
		
        if Defaults.shouldDebugDrawing {
			self.backgroundColor = .systemPurple
		}
		else {
			self.backgroundColor = .clear
		}
        
        let contentView = NSView(frame: frame)
        contentView.wantsLayer = true;

        self.contentView = contentView
        createNotchView(size: notchRect.size)

	}

    private func createNotchView(size: NSSize) {
        guard let contentView = contentView else { return }

        let contentBounds = contentView.bounds
        let notchFrame = CGRect(origin: CGPoint(x: contentBounds.midX - size.width / 2, y: contentBounds.maxY - size.height), size: size)
        let notchView = NotchView(frame: notchFrame)
        contentView.addSubview(notchView)
        
        self.notchView = notchView
    }
    
	override func orderFront(_ sender: Any?) {
		super.orderFront(sender)
		
		activateTrackingArea()
	}
	
	override func orderOut(_ sender: Any?) {
		super.orderOut(sender)
		
		deactivateTrackingArea()
	}
	
	//MARK: - NSTrackingArea
	
	private func activateTrackingArea() {
		if let contentView = contentView {
			if self.trackingArea == nil {
				// create a tracking area for mouse movements
				// NOTE: This was initially on the NotchView, but it was unreliable, probably due to the use of layer hosting views.
				// To workaround this issue, the content view acts as a proxy and the NSResponder methods in this class forward the
				// mouse events to the NotchView (which, in turn, forwards them onto the NotchEffect).
				let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .mouseMoved]
				let trackingRect = contentView.bounds
				let trackingArea = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
				self.trackingArea = trackingArea
				contentView.addTrackingArea(trackingArea)
			}
		}
	}
	
	private func deactivateTrackingArea() {
		if let contentView = contentView {
			if let trackingArea = self.trackingArea {
				contentView.removeTrackingArea(trackingArea)
				self.trackingArea = nil
			}
		}
	}

	//MARK: - NSResponder
	
	override func mouseEntered(with event: NSEvent) {
		self.notchView?.mouseEntered(windowPoint: event.locationInWindow)
	}
	
	override func mouseMoved(with event: NSEvent) {
		self.notchView?.mouseMoved(windowPoint: event.locationInWindow)
	}
	
	override func mouseExited(with event: NSEvent) {
		self.notchView?.mouseExited(windowPoint: event.locationInWindow)
	}
	
}

extension NotchWindow: NSWindowDelegate {
	
}
