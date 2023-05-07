//
//  DebugViewController.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

class DebugViewController: NSViewController {

    @IBOutlet weak var debugDrawingCheckbox: NSButton!
    @IBOutlet weak var fakeNotchCheckbox: NSButton!
	@IBOutlet weak var largeFakeNotchCheckbox: NSButton!
	@IBOutlet weak var deactivateFakeNotchCheckbox: NSButton!
    @IBOutlet weak var outlineNotchCheckbox: NSButton!
    @IBOutlet weak var fillNotchCheckbox: NSButton!
	@IBOutlet weak var textNotchCheckbox: NSButton!
	@IBOutlet weak var alternateDiceCheckbox: NSButton!

    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForDefaults()
    }
    
    private func configureForDefaults() {
		Defaults.register()
		
        debugDrawingCheckbox.state = Defaults.shouldDebugDrawing ? .on : .off
        fakeNotchCheckbox.state = Defaults.shouldFakeNotch ? .on : .off
		largeFakeNotchCheckbox.state = Defaults.shouldLargeFakeNotch ? .on : .off
		deactivateFakeNotchCheckbox.state = Defaults.shouldDeactivateFakeNotch ? .on : .off
        outlineNotchCheckbox.state = Defaults.shouldDrawNotchOutline ? .on : .off
        fillNotchCheckbox.state = Defaults.shouldDrawNotchFill ? .on : .off
		textNotchCheckbox.state = Defaults.shouldDrawNotchText ? .on : .off
		alternateDiceCheckbox.state = Defaults.shouldUseAlternateDice ? .on : .off
    }
        
    //MARK: - Actions
    
	private func updateConfiguration() {
		guard let viewController = presentingViewController as? ViewController else { return }
		viewController.updateConfiguration()
	}
	
    @IBAction func debugDrawingValueChanged(_ sender: Any) {
        Defaults.shouldDebugDrawing = (debugDrawingCheckbox.state == .on)
		updateConfiguration()
    }
    
    @IBAction func fakeNotchValueChanged(_ sender: Any) {
        Defaults.shouldFakeNotch = (fakeNotchCheckbox.state == .on)
		updateConfiguration()
    }

	@IBAction func largeFakeNotchValueChanged(_ sender: Any) {
		Defaults.shouldLargeFakeNotch = (largeFakeNotchCheckbox.state == .on)
		updateConfiguration()
	}

	@IBAction func deactivateFakeNotchValueChanged(_ sender: Any) {
		Defaults.shouldDeactivateFakeNotch = (deactivateFakeNotchCheckbox.state == .on)
		updateConfiguration()
	}

    @IBAction func outlineNotchValueChanaged(_ sender: Any) {
        Defaults.shouldDrawNotchOutline = (outlineNotchCheckbox.state == .on)
		updateConfiguration()
    }
    
    @IBAction func fillNotchValueChanged(_ sender: Any) {
        Defaults.shouldDrawNotchFill = (fillNotchCheckbox.state == .on)
		updateConfiguration()
    }

	@IBAction func textNotchValueChanged(_ sender: Any) {
		Defaults.shouldDrawNotchText = (textNotchCheckbox.state == .on)
		updateConfiguration()
	}

	@IBAction func alternateDiceValueChanged(_ sender: Any) {
		Defaults.shouldUseAlternateDice = (alternateDiceCheckbox.state == .on)
		updateConfiguration()
	}

	@IBAction func resetDefaults(_ sender: Any) {
		Defaults.reset()	
		configureForDefaults()
		updateConfiguration()
	}
}

