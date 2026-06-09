//
//  SettingsViewController.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 6/8/26.
//

import Cocoa

class SettingsViewController: NSViewController {

	@IBOutlet weak var alternateDiceCheckbox: NSButton!
	@IBOutlet weak var hideControlPanelCheckbox: NSButton!
	@IBOutlet weak var activateUnderNotchCheckbox: NSButton!
	@IBOutlet weak var hideWindowAtLaunchCheckbox: NSButton!

    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForDefaults()
    }
    
    private func configureForDefaults() {
		Defaults.register()
		
		alternateDiceCheckbox.state = Defaults.shouldUseAlternateDice ? .on : .off
		if Defaults.shouldFakeNotch {
			hideControlPanelCheckbox.isEnabled = false
			hideControlPanelCheckbox.state = .off
		}
		else {
			hideControlPanelCheckbox.isEnabled = true
			hideControlPanelCheckbox.state = Defaults.shouldHideControlPanel ? .on : .off
		}
		if Defaults.shouldHideDockIcon {
			activateUnderNotchCheckbox.isEnabled = true
			activateUnderNotchCheckbox.state = Defaults.shouldActivateUnderNotch ? .on : .off
			
			if Defaults.shouldActivateUnderNotch {
				hideWindowAtLaunchCheckbox.isEnabled = true
				hideWindowAtLaunchCheckbox.state = Defaults.shouldHideWindowAtLaunch ? .on : .off
			}
			else {
				hideWindowAtLaunchCheckbox.isEnabled = false
				hideWindowAtLaunchCheckbox.state = .off
			}
		}
		else {
			activateUnderNotchCheckbox.isEnabled = false
			activateUnderNotchCheckbox.state = .off
			
			hideWindowAtLaunchCheckbox.isEnabled = false
			hideWindowAtLaunchCheckbox.state = .off
		}
    }
        
    //MARK: - Actions
    
	private func updateConfiguration() {
		guard let viewController = presentingViewController as? ViewController else { return }
		viewController.updateConfiguration()
	}
	
	@IBAction func alternateDiceValueChanged(_ sender: Any) {
		Defaults.shouldUseAlternateDice = (alternateDiceCheckbox.state == .on)
		updateConfiguration()
	}

	@IBAction func hideControlPanelChanged(_ sender: Any) {
		Defaults.shouldHideControlPanel = (hideControlPanelCheckbox.state == .on)
		updateConfiguration()
	}

	@IBAction func activateUnderNotchChanged(_ sender: Any) {
		Defaults.shouldActivateUnderNotch = (activateUnderNotchCheckbox.state == .on)
		updateConfiguration()

		if Defaults.shouldActivateUnderNotch {
			hideWindowAtLaunchCheckbox.isEnabled = true
			hideWindowAtLaunchCheckbox.state = Defaults.shouldHideWindowAtLaunch ? .on : .off
		}
		else {
			hideWindowAtLaunchCheckbox.isEnabled = false
			hideWindowAtLaunchCheckbox.state = .off
		}
	}

	@IBAction func hideWindowAtLaunchChanged(_ sender: Any) {
		Defaults.shouldHideWindowAtLaunch = (hideWindowAtLaunchCheckbox.state == .on)
		updateConfiguration()
	}

	@IBAction func resetDefaults(_ sender: Any) {
		Defaults.reset()
		if !NSScreen.hasNotchedScreen {
			Defaults.shouldFakeNotch = true
		}
		else {
			Defaults.shouldFakeNotch = false
		}

		configureForDefaults()
		updateConfiguration()
	}
}

