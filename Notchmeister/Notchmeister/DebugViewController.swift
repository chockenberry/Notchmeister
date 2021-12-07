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
    }
        
    //MARK: - Actions
    
	private func updateWindows() {
		guard let viewController = presentingViewController as? ViewController else { return }
		viewController.updateWindows()
	}
	
    @IBAction func debugDrawingValueChanged(_ sender: Any) {
        Defaults.shouldDebugDrawing = (debugDrawingCheckbox.state == .on)
		updateWindows()
    }
    
    @IBAction func fakeNotchValueChanged(_ sender: Any) {
        Defaults.shouldFakeNotch = (fakeNotchCheckbox.state == .on)
		updateWindows()
    }

	@IBAction func largeFakeNotchValueChanged(_ sender: Any) {
		Defaults.shouldLargeFakeNotch = (largeFakeNotchCheckbox.state == .on)
		updateWindows()
	}

	@IBAction func deactivateFakeNotchValueChanged(_ sender: Any) {
		Defaults.shouldDeactivateFakeNotch = (deactivateFakeNotchCheckbox.state == .on)
		updateWindows()
	}


    @IBAction func outlineNotchValueChanaged(_ sender: Any) {
        Defaults.shouldDrawNotchOutline = (outlineNotchCheckbox.state == .on)
		updateWindows()
    }
    
    @IBAction func fillNotchValueChanged(_ sender: Any) {
        Defaults.shouldDrawNotchFill = (fillNotchCheckbox.state == .on)
		updateWindows()
    }

}

