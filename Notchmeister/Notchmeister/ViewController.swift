//
//  ViewController.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

class ViewController: NSViewController {

	var notchWindows: [NotchWindow] = []
	var notchViews: [NotchView] = []
	
    @IBOutlet weak var debugDrawingCheckbox: NSButton!
    @IBOutlet weak var fakeNotchCheckbox: NSButton!
    @IBOutlet weak var outlineNotchCheckbox: NSButton!
    @IBOutlet weak var fillNotchCheckbox: NSButton!
	@IBOutlet weak var effectPopUpButton: NSPopUpButton!

    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForDefaults()
        createNotchWindows()
    }
    
    private func configureForDefaults() {
        debugDrawingCheckbox.state = Defaults.shouldDebugDrawing ? .on : .off
        fakeNotchCheckbox.state = Defaults.shouldFakeNotch ? .on : .off
        outlineNotchCheckbox.state = Defaults.shouldDrawNotchOutline ? .on : .off
        fillNotchCheckbox.state = Defaults.shouldDrawNotchFill ? .on : .off
		
		effectPopUpButton.selectItem(withTag: Defaults.selectedEffect)
    }
    
    private func createNotchWindows() {
        let padding: CGFloat = 50
        
        for oldWindow in notchWindows {
            oldWindow.orderOut(self)
        }

        notchWindows.removeAll()
        notchViews.removeAll()
        
		for screen in NSScreen.notchedScreens {
			if let notchWindow = NotchWindow(screen: screen, padding: padding) {
				let contentView = NSView(frame: notchWindow.frame)
				contentView.wantsLayer = true;

				if let notchRect = screen.notchRect {
					let contentBounds = contentView.bounds
					let notchFrame = CGRect(origin: CGPoint(x: contentBounds.midX - notchRect.width / 2, y: contentBounds.maxY - notchRect.height), size: notchRect.size)
					let notchView = NotchView(frame: notchFrame)
					contentView.addSubview(notchView)
                    notchViews.append(notchView)
				}

				notchWindow.contentView = contentView
				notchWindow.orderFront(self)
        
                notchWindows.append(notchWindow)
			}
		}
    }
    
    //MARK: - Actions
    
    @IBAction func debugDrawingValueChanged(_ sender: Any) {
        Defaults.shouldDebugDrawing = (debugDrawingCheckbox.state == .on)
        createNotchWindows()
    }
    
    @IBAction func fakeNotchValueChanged(_ sender: Any) {
        Defaults.shouldFakeNotch = (fakeNotchCheckbox.state == .on)
        createNotchWindows()
    }
    
    @IBAction func outlineNotchValueChanaged(_ sender: Any) {
        Defaults.shouldDrawNotchOutline = (outlineNotchCheckbox.state == .on)
        notchViews.forEach {
            $0.needsDisplay = true
        }
    }
    
    @IBAction func fillNotchValueChanged(_ sender: Any) {
        Defaults.shouldDrawNotchFill = (fillNotchCheckbox.state == .on)
        notchViews.forEach {
            $0.needsDisplay = true
        }
    }

	@IBAction func selectedEffectValueChanged(_ sender: Any) {
		Defaults.selectedEffect = effectPopUpButton.selectedTag()
		createNotchWindows()
	}
}

