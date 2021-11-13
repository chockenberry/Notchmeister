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

