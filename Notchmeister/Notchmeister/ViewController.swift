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

		let padding: CGFloat = 20
		
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

}

