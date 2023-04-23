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

	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		//self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size, flipped: true)

		super.init(with: parentLayer, in: parentView, of: parentWindow)
		

		//configureSublayers()
		configureChildWindow()
	}
	
	private func configureChildWindow() {
		let contentRect = CGRect(x: 0, y: 0, width: 400, height: 300)

		let childWindow = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
		childWindow.ignoresMouseEvents = false
		childWindow.canHide = false
		childWindow.isMovable = false
		childWindow.isOpaque = false
		childWindow.hasShadow = false
		
		let viewRect = CGRect(x: 0, y: 0, width: 400, height: 300)
#if true
		//let contentView = SceneView(frame: viewRect)
		let scene = SCNScene(named: "dice.scn")!
		//scene.background.contents = NSColor.systemYellow.withAlphaComponent(0.5)
		let contentView = SCNView(frame: viewRect)
		contentView.backgroundColor = NSColor.clear
		contentView.scene = scene
		contentView.wantsLayer = false

		let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
		var gestureRecognizers = contentView.gestureRecognizers
		gestureRecognizers.insert(clickGesture, at: 0)
		contentView.gestureRecognizers = gestureRecognizers

#else
		let contentView = NSImageView(frame: viewRect)
		contentView.imageAlignment = .alignCenter
		contentView.image = NSImage(named: "xray")
		contentView.wantsLayer = false
		//contentView.wantsLayer = true;
#endif
		childWindow.contentView = contentView

#if false
		if Defaults.shouldDebugDrawing {
			childWindow.backgroundColor = .systemYellow.withAlphaComponent(0.5)
		}
		else {
			childWindow.backgroundColor = .clear
		}
#else
		childWindow.backgroundColor = .clear
#endif
		
		if let window = parentWindow {
			window.addChildWindow(childWindow, ordered: .below)
		}
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		debugLog()
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		do {
			if underNotch {
				debugLog()
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
	
}

