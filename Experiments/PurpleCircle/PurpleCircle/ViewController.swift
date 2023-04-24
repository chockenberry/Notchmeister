//
//  ViewController.swift
//  PurpleCircle
//
//  Created by Craig Hockenberry on 4/24/23.
//

import Cocoa

import SceneKit

class ViewController: NSViewController {

	private var sceneWindow: NSWindow!
	private var normalWindow: NSWindow!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		sceneWindow = configureWindow(forScene: true)
		normalWindow = configureWindow(forScene: false)
	}

	override func viewWillLayout() {
		super.viewWillLayout()

		sceneWindow.orderFront(self)
		normalWindow.orderFront(self)
	}
	
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	private func configureWindow(forScene: Bool) -> NSWindow? {
		guard let screen = NSScreen.screens.first else { return nil }
		
		let contentRect: NSRect
		if forScene {
			contentRect = CGRect(x: screen.frame.midX - 400, y: screen.frame.midY - 150, width: 400, height: 300)
		}
		else {
			contentRect = CGRect(x: screen.frame.midX + 0, y: screen.frame.midY - 150, width: 400, height: 300)
		}

		let window = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
		//window.ignoresMouseEvents = false
		window.canHide = false
		window.isMovable = false
		window.isOpaque = false
		window.hasShadow = false
		//window.level = .popUpMenu
		window.level = .normal
		//window.alphaValue = 0
		//window.hasShadow = true

		let viewRect = CGRect(x: 0, y: 0, width: 400, height: 300)
		let contentView: NSView
		if forScene {
			let scene = SCNScene(named: "sphere.scn")!
			//scene.background.contents = nil
			let sceneView = SceneView(frame: viewRect)
			sceneView.backgroundColor = .clear
			sceneView.scene = scene
			//sceneView.rendersContinuously = true
			//sceneView.stop(self)
			//sceneView.layer?.setValue(true, forKey: "hitTestsContentsAlphaChannel")
			//sceneView.drawableResizesAsynchronously = false
			//sceneView.antialiasingMode = .none
			
			contentView = sceneView
		}
		else {
			contentView = NormalView(frame: viewRect)
		}

		contentView.wantsLayer = false

		window.contentView = contentView

#if false
		window.backgroundColor = .systemYellow.withAlphaComponent(0.5)
#else
		window.backgroundColor = .clear
#endif
		
		return window
	}


}

