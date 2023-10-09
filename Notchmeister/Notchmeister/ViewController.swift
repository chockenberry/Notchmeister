//
//  ViewController.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

class ViewController: NSViewController {

	var notchWindows: [NotchWindow] = []
	var screenParametersNotificationObserver: NSObjectProtocol? = nil
	var applicationActivationNotificationObserver: NSObjectProtocol? = nil

	@IBOutlet weak var effectPopUpButton: NSPopUpButton!
	@IBOutlet weak var effectDescriptionTextField: NSTextField!
	@IBOutlet weak var debugButton: NSButton!
	@IBOutlet weak var hideDockButton: NSButton!

    //MARK: - Life Cycle

	deinit {
		// we don't want this view controller, and its notchWindows, to go away
		assert(false, "view controller can't be deallocated")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		debugButton.isHidden = true

        configureForDefaults()

		self.screenParametersNotificationObserver = NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: nil) { [weak self] note in
			debugLog("screen parameters changed, updating configuration...")
			if #available(macOS 14, *) {
				if Defaults.shouldFakeNotch {
					// NOTE: On macOS Sonoma, creating the fake notch windows causes the screen parameters to change.
					// Calling updateConfiguration causes new windows to be created and initiates an endless loop of change
					// notifications.
					//
					// Rather than dive into what is probably a nasty side effect of the CGDisplayStream change detection, the
					// notification is just ignored. A reasonable compromise for a demo.
					return
				}
			}
			self?.updateConfiguration()
		}

		self.applicationActivationNotificationObserver = NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] note in
			// NOTE: The hidesOnDeactivate for the NotchWindow gets into a weird state if the windows are created before the application is active. To mitigate this
			// we only create the windows after the first activation (when there are no existing windows).
			if let self, self.notchWindows.count == 0 {
				debugLog("application activated, creating initial notch windows...")
				self.createNotchWindows()
			}
		}

    }

    private func configureForDefaults() {
		Defaults.register()
		
		let menu = NSMenu(title: "Notch Effects")
		for effect in Effects.allCases {
			let menuItem = NSMenuItem(title: effect.displayName(), action: nil, keyEquivalent: "")
			menuItem.tag = effect.rawValue
			menu.addItem(menuItem)
		}
		effectPopUpButton.menu = menu
		
		guard let effect = Effects(rawValue: Defaults.selectedEffect) else { return }
		effectDescriptionTextField.stringValue = effect.displayDescription()
		effectPopUpButton.selectItem(withTag: effect.rawValue)
		
		hideDockButton.state = Defaults.shouldHideDockIcon ? .on : .off
    }
    
    private func createNotchWindows() {
        for oldWindow in notchWindows {
            oldWindow.orderOut(self)
        }

        notchWindows.removeAll()
        
		for screen in NSScreen.notchedScreens {
			if let notchWindow = NotchWindow(screen: screen) {
				notchWindow.orderFront(self)
                notchWindows.append(notchWindow)
			}
		}
    }
    
	func updateConfiguration() {
		// called from DebugViewController to rebuild window and view hierarchies when settings change
		configureForDefaults()
		createNotchWindows()
	}
	
    //MARK: - Actions

	@IBAction func openDebugViewController(_ sender: Any) {
		guard let viewController = self.storyboard?.instantiateController(withIdentifier: "debugViewController") as? NSViewController else { return }
		self.present(viewController, asPopoverRelativeTo: debugButton.frame, of: view, preferredEdge: NSRectEdge.minX, behavior: .transient)
	}
	
	@IBAction func selectedEffectValueChanged(_ sender: Any) {
		Defaults.selectedEffect = effectPopUpButton.selectedTag()
		createNotchWindows()
		
		guard let effect = Effects(rawValue: Defaults.selectedEffect) else { return }
		effectDescriptionTextField.stringValue = effect.displayDescription()
	}
	
	@IBAction func hideDockIconValueChanged(_ sender: Any) {
		Defaults.shouldHideDockIcon = hideDockButton.state == .on

		createNotchWindows()

		if Defaults.shouldHideDockIcon {
			NSApplication.shared.setActivationPolicy(.accessory)
			NSApplication.shared.activate(ignoringOtherApps: true)
		}
		else {
			NSApplication.shared.setActivationPolicy(.regular)
		}
	}

	@IBAction func quitApplication(_ sender: Any) {
		NSApplication.shared.terminate(self)
	}

	@IBAction func openHelp(_ sender: Any) {
		if NSEvent.modifierFlags.contains(.option) {
			// NOTE: Turn on the debug button by holding down the Option key while clicking the Help button.
			debugButton.isHidden = false
		}
		else {
			let alert = NSAlert()
			alert.messageText = "Notchmeister Help"
			if NSScreen.hasNotchedScreen {
				alert.informativeText = Defaults.notchedHelp + Defaults.githubHelpButton
			}
			else {
				alert.informativeText = Defaults.notchlessHelp + Defaults.githubHelpButton
			}
			alert.addButton(withTitle: "OK")
			alert.addButton(withTitle: "Open GitHub…")
			let result = alert.runModal()
			if result == .alertSecondButtonReturn {
				debugLog("open github…")
				NSWorkspace.shared.open(Defaults.gitHubUrl)
			}
		}
	}
}

