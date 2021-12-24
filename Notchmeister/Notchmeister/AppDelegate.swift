//
//  AppDelegate.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationWillFinishLaunching(_ notification: Notification) {
//		if ([userDefaults boolForKey:hideDockIconKey]) {
//			[NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
//		}
//		else {
//			[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
//		}
		if Defaults.shouldHideDockIcon {
			NSApplication.shared.setActivationPolicy(.accessory)
		}
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
        Defaults.register()
		
#if !DEBUG
		if !NSScreen.hasNotchedScreen {
			let alert = NSAlert()
			alert.messageText = "Notch Simulation Mode"
			alert.informativeText = Defaults.notchlessHelp + Defaults.notchlessHelpIntro
			alert.runModal()
			
			Defaults.shouldFakeNotch = true
		}
		else {
			Defaults.shouldFakeNotch = false
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
			// NOTE: The window that triggered this activation could have been the child window underneath the NotchWindow.
			// Since that window is borderless and we could be running with the .accessory activation policy, we need to ensure
			// that the app is frontmost before ordering the window.
			NSApplication.shared.activate(ignoringOtherApps: true)
			
			window.makeKeyAndOrderFront(self)
		}
	}
	
	@IBAction func openTwitter(_ sender: Any) {
		guard let url = URL(string: "https://twitter.com/notchmeister") else { NSSound.beep(); return }
		NSWorkspace.shared.open(url)
	}

	@IBAction func openGitHub(_ sender: Any) {
		guard let url = URL(string: "https://github.com/chockenberry/Notchmeister") else { NSSound.beep(); return }
		NSWorkspace.shared.open(url)
	}

	@IBAction func openWindow(_ sender: Any) {
		if let window = NSApplication.shared.windows.first {
			window.makeKeyAndOrderFront(self)
		}
	}
	
}

