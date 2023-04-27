//
//  AppDelegate.swift
//  PurpleCircle
//
//  Created by Craig Hockenberry on 4/24/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}

	func applicationDidBecomeActive(_ notification: Notification) {
		debugLog()
	}

}

