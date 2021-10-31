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

}

