//
//  AppDelegate.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

#if DEBUG
	let DEBUG_DRAWING = true
	let FAKE_NOTCH = true
#else
	let DEBUG_DRAWING = false
	let FAKE_NOTCH = false
#endif

@main
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true;
	}

}

