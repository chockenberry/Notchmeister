//
//  DiceEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit
import SceneKit

class DiceEffect: NotchEffect {
	
	//var edgeLayer: CAShapeLayer

	var diceWindow: NSWindow!
	
	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		//self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size, flipped: true)

		super.init(with: parentLayer, in: parentView, of: parentWindow)
		

		//configureSublayers()
		//self.perform(#selector(configureChildWindow), with: nil, afterDelay: 2.0)
		//configureChildWindow()
		
		diceWindow = configureDiceWindow()
		diceWindow.orderFront(self)

	}
	
	deinit {
		diceWindow.orderOut(self)
	}
		
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		debugLog()
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		//guard let parentLayer = parentLayer else { return }

		do {
			if underNotch {
				//debugLog()
			}
			else {
			}
		}

	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		debugLog()
	}

	@objc
	func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
#if true
		debugLog()
#else
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// check what nodes are clicked
		let p = gestureRecognizer.location(in: scnView)
		let hitResults = scnView.hitTest(p, options: [:])
		// check that we clicked on at least one object
		if hitResults.count > 0 {
			let node = hitResults.first!.node
			debugLog("node = \(node)")
		}
#endif
	}
	
	private func configureDiceWindow() -> NSWindow? {
		guard let screen = NSScreen.screens.first else { return nil }
		
//		let contentRect = CGRect(x: screen.frame.midX - 400, y: screen.frame.midY - 150, width: 400, height: 300)
		let contentRect = CGRect(x: 0, y: 0, width: 400, height: 300)

		let window = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
		window.canHide = false
		window.isMovable = false
		window.isOpaque = false
		window.hasShadow = false
		window.level = .popUpMenu
		
		let viewRect = CGRect(x: 0, y: 0, width: 400, height: 300)
		let contentView = DiceView(frame: viewRect)
		contentView.imageAlignment = .alignCenter
		contentView.image = NSImage(named: "xray")
		contentView.wantsLayer = false

		window.title = "Dice Window"
		window.contentView = contentView

		window.backgroundColor = .clear
//		window.alphaValue = 0.25
		window.alphaValue = 0.05

		return window
	}

}

