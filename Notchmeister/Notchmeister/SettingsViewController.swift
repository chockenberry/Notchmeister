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

    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForDefaults()
    }
    
    private func configureForDefaults() {
		Defaults.register()
		
		alternateDiceCheckbox.state = Defaults.shouldUseAlternateDice ? .on : .off
		hideControlPanelCheckbox.state = Defaults.shouldHideControlPanel ? .on : .off
		activateUnderNotchCheckbox.state = Defaults.shouldActivateUnderNotch ? .on : .off
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

