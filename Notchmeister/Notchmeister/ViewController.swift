//
//  ViewController.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import Cocoa

class ViewController: NSViewController {

	var notchWindow: NotchWindow?
	var notchView: NotchView?
	
    @IBOutlet weak var debugDrawingCheckbox: NSButton!
    
    @IBOutlet weak var fakeNotchCheckbox: NSButton!
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForDefaults()
        createNotchWindow()
    }
    
    private func configureForDefaults() {
        debugDrawingCheckbox.state = .off
        fakeNotchCheckbox.state = .off
        
        if Defaults.shouldDebugDrawing {
            debugDrawingCheckbox.state = .on
        }
        
        if Defaults.shouldFakeNotch {
            fakeNotchCheckbox.state = .on
        }
    }
    
    private func createNotchWindow() {
        let padding: CGFloat = 50
        
        if let oldWindow = notchWindow {
            oldWindow.orderOut(self)
        }
        
        notchWindow = NotchWindow(padding: padding)
        if let notchWindow = notchWindow {
            let contentView = NSView(frame: notchWindow.frame)
            contentView.wantsLayer = true;
            
            if let notchRect = NSScreen.notched?.notchRect {
                let contentBounds = contentView.bounds
                let notchFrame = CGRect(origin: CGPoint(x: contentBounds.midX - notchRect.width / 2, y: contentBounds.maxY - notchRect.height), size: notchRect.size)
                let notchView = NotchView(frame: notchFrame)
                contentView.addSubview(notchView)
            }

            notchWindow.contentView = contentView
            
            notchWindow.orderFront(self)
        }
    }
    
    //MARK: - Actions
    
    @IBAction func debugDrawingValueChanged(_ sender: Any) {
        Defaults.shouldDebugDrawing = (debugDrawingCheckbox.state == .on)
        createNotchWindow()
    }
    
    @IBAction func fakeNotchValueChanged(_ sender: Any) {
        Defaults.shouldFakeNotch = (fakeNotchCheckbox.state == .on)
        createNotchWindow()
    }
}

