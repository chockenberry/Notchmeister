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
        
        configureForDefaults()
        createNotchWindows()

		self.screenParametersNotificationObserver = NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: nil) { [weak self] note in
			self?.updateConfiguration()
		}
    }

	override func viewWillDisappear() {
		debugLog()
		
		// NOTE: Turn on the debug button in the release build by holding down the Option key while closing the main window,
		// then reopen the window using the Dock icon.
		if NSEvent.modifierFlags.contains(.option) {
			debugButton.isHidden = false
		}

		if let observer = self.screenParametersNotificationObserver {
			NotificationCenter.default.removeObserver(observer)
			self.screenParametersNotificationObserver = nil
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
		
#if DEBUG
		debugButton.isHidden = false
#else
		debugButton.isHidden = true
#endif
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
		}
		else {
			NSApplication.shared.setActivationPolicy(.regular)
		}
	}
	
	@IBAction func openHelp(_ sender: Any) {
		let alert = NSAlert()
		alert.messageText = "Notchmeister Help"
		if NSScreen.hasNotchedScreen {
			alert.informativeText = Defaults.notchedHelp
		}
		else {
			alert.informativeText = Defaults.notchlessHelp + Defaults.notchlessHelpButton
		}
		alert.runModal()
	}
}

