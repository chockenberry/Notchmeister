//
//  AppDelegate.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
        Defaults.register()
		
#if !DEBUG
		if !NSScreen.hasNotchedScreen {
			let alert = NSAlert()
			alert.messageText = "Notch Simulation Mode"
			alert.informativeText = "This Mac doesn’t have a notch.\n\nThanks to Notchmeister‘s built-in genuine replacement notch, you can still join in on the fun. This replacement part, like all others, doesn't quite work as original. The notch height is a bit shorter and the mouse won‘t disappear underneath it.\n\nNote also that the replacement notch only appears when the app is active: this prevents it from interfering with a long menu bar in another app.\n\nSide-effects of this app include making you want a new MacBook Pro even more than you already do. Sorry."
			alert.runModal()
		}
#endif
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true;
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		// clicking on the Dock icon will cause the main window to reappear
		if let window = sender.windows.first {
			window.makeKeyAndOrderFront(self)
		}
		return false
	}

	func applicationDidBecomeActive(_ notification: Notification) {
		if let window = NSApplication.shared.windows.first {
			window.makeKeyAndOrderFront(self)
		}
	}
}

