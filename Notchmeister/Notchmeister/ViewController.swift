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
	
	override func viewDidLoad() {
		super.viewDidLoad()

		notchWindow = NotchWindow(fakeANotch: FAKE_NOTCH)
		if let notchWindow = notchWindow {
			let contentView = NSView(frame: notchWindow.frame)
			contentView.wantsLayer = true;
			
			let notchView = NotchView(frame: contentView.bounds)
			contentView.addSubview(notchView)
			notchWindow.contentView = contentView
			
			notchWindow.orderFront(self)
		}
	}

}

