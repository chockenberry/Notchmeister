//
// Created by cparrish on 10/28/2021
//

import Cocoa

import CoreGraphics

class NotchWindow: NSWindow {
    
    var notchView: NotchView?
	var fakeNotchView: FakeNotchView?

	static let padding: CGFloat = 50 // amount of padding around the notch that can be used for effect drawing
	static let activationPadding: CGFloat = 6 // amount of padding around the notch that can be used for activating the settings window

	required init?(screen: NSScreen) {
		guard let notchRect = screen.notchRect else { return nil }
        
		let contentRect = CGRect(x: notchRect.origin.x - Self.padding, y: notchRect.origin.y - Self.padding, width: notchRect.width + (Self.padding * 2), height: notchRect.height + Self.padding)
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        
		// NOTE: In theory, we should be able to create a window above the cursor. In practice, this doesn't work.
		// More info: https://jameshfisher.com/2020/08/03/what-is-the-order-of-nswindow-levels/
		//self.level = NSWindow.Level.init(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
		//self.level = .screenSaver
		//self.level = .statusBar
		self.level = .popUpMenu // NOTE: I think this is probably best - keeps the window under a screensaver.
		if Defaults.shouldFakeNotch {
			if Defaults.shouldDeactivateFakeNotch && !Defaults.shouldHideDockIcon {
				self.hidesOnDeactivate = true // use true to keep fake notch from interfering with other apps
			}
			else {
				self.hidesOnDeactivate = false // use false to simulate how real notch works
			}
		}
		else {
			self.hidesOnDeactivate = false
		}
		self.ignoresMouseEvents = true // clicking on the window does not make the app frontmost
        self.canHide = false
        self.isMovable = false
        self.isOpaque = false
        self.hasShadow = false
		// TODO: .transient works well for fake notch (so it goes away with Exposé), .stationary is better with a real notch (stays put with Exposé)
        self.collectionBehavior = [.transient, .canJoinAllSpaces]
//		self.acceptsMouseMovedEvents = true
		
		if Defaults.shouldHideDockIcon {
			let contentRect = CGRect(x: notchRect.origin.x - Self.activationPadding, y: notchRect.origin.y - Self.activationPadding, width: notchRect.width + (Self.activationPadding * 2), height: notchRect.height + Self.activationPadding)

			let childWindow = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
			childWindow.ignoresMouseEvents = false
			childWindow.canHide = false
			childWindow.isMovable = false
			childWindow.isOpaque = false
			childWindow.hasShadow = false
			
			debugLog("notchRect.size = \(notchRect.size)")
			let contentView = ActivationView(frame: notchRect)
			contentView.wantsLayer = false
			//contentView.wantsLayer = true;
			
			childWindow.contentView = contentView
			
			if Defaults.shouldDebugDrawing {
				childWindow.backgroundColor = .systemBlue.withAlphaComponent(0.5)
			}
			else {
				childWindow.backgroundColor = .clear
			}
			
			self.addChildWindow(childWindow, ordered: .below)
		}
		
        if Defaults.shouldDebugDrawing {
			self.backgroundColor = .systemPurple.withAlphaComponent(0.25)
		}
		else {
			self.backgroundColor = .clear
		}
        
        //let contentView = NSView(frame: frame)
		// NOTE: This was initially on the NotchView, but it was unreliable, probably due to the use of
		// layer hosting views and/or the tracking rect being outside the bounds of the notch.
		// To workaround this issue, the content view acts as a proxy and the NSResponder methods in
		// this class forward the mouse events to the NotchView (which, in turn, forwards them onto
		// the NotchEffect).
		let contentView = TrackingView(frame: frame)
		contentView.wantsLayer = false
        //contentView.wantsLayer = true;

        self.contentView = contentView
        createNotchView(size: notchRect.size)
		
		if Defaults.shouldFakeNotch {
			createFakeNotchView(size: notchRect.size)
		}
		
//		self.delegate = self
	}

	override func orderFront(_ sender: Any?) {
		super.orderFront(sender)
		
		if let fakeNotchView = fakeNotchView {
			debugLog("starting")
			fakeNotchView.alphaValue = 1.0
			let destinationFrame = fakeNotchView.frame
			let sourceFrame = NSRect(origin: CGPoint(x: destinationFrame.origin.x, y: destinationFrame.origin.y + destinationFrame.height), size: destinationFrame.size)
			fakeNotchView.frame = sourceFrame
			NSAnimationContext.runAnimationGroup { context in
				context.duration = 0.5
				fakeNotchView.animator().frame = destinationFrame
			} completionHandler: {
				debugLog("finished")
			}
		}
	}
	
	override func orderOut(_ sender: Any?) {
		if let trackingView = contentView as? TrackingView {
			trackingView.disable()
		}
		
		if let fakeNotchView = fakeNotchView {
			debugLog("starting")
			fakeNotchView.alphaValue = 1.0
			NSAnimationContext.runAnimationGroup { context in
				context.duration = 0.25
				fakeNotchView.animator().alphaValue = 0.0
			} completionHandler: {
				debugLog("finished")
				super.orderOut(sender)
			}
		}
		else {
			super.orderOut(sender)
		}
	}

    private func createNotchView(size: NSSize) {
        guard let contentView = contentView else { return }

        let contentBounds = contentView.bounds
        let notchFrame = CGRect(origin: CGPoint(x: contentBounds.midX - size.width / 2, y: contentBounds.maxY - size.height), size: size)
        let notchView = NotchView(frame: notchFrame)
        contentView.addSubview(notchView)
        
        self.notchView = notchView
    }
	
	private func createFakeNotchView(size: NSSize) {
		guard let contentView = contentView else { return }

		let contentBounds = contentView.bounds
		let notchFrame = CGRect(origin: CGPoint(x: contentBounds.midX - size.width / 2, y: contentBounds.maxY - size.height), size: size)

		let bundle = Bundle.main
		var topLevelArray: NSArray? = nil
		bundle.loadNibNamed("FakeNotchView", owner: self, topLevelObjects: &topLevelArray)
		if let topLevelArray = topLevelArray {
			let views = Array<Any>(topLevelArray).filter { $0 is FakeNotchView }
			if let fakeNotchView = views.last as? FakeNotchView {
				fakeNotchView.frame = notchFrame
				self.contentView?.addSubview(fakeNotchView)
				self.fakeNotchView = fakeNotchView
			}
		}
	}
	
	//MARK: - NSResponder
	
	override func mouseEntered(with event: NSEvent) {
		//debugLog()
		self.notchView?.mouseEntered(windowPoint: event.locationInWindow)
	}
	
	override func mouseMoved(with event: NSEvent) {
		//debugLog()
		self.notchView?.mouseMoved(windowPoint: event.locationInWindow)
	}
	
	override func mouseExited(with event: NSEvent) {
		//debugLog()
		self.notchView?.mouseExited(windowPoint: event.locationInWindow)
	}
	
}

extension NotchWindow: NSWindowDelegate {
	
//	func windowDidUpdate(_ notification: Notification) {
//		debugLog()
//	}

}
