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
	private var imageWindow: NSWindow!
	private var normalWindow: NSWindow!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		sceneWindow = configureWindow(forScene: true)
		sceneWindow.ignoresMouseEvents = true

		imageWindow = configureImageWindow()
		sceneWindow.addChildWindow(imageWindow, ordered: .above)
		
		normalWindow = configureWindow(forScene: false)
	}

	override func viewWillLayout() {
		super.viewWillLayout()

		sceneWindow.orderFront(self)
		imageWindow.order(.above, relativeTo: sceneWindow.windowNumber)
		//imageWindow.orderFront(self)
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
			
			sceneView.delegate = self
			
			let sphere = scene.rootNode.childNode(withName: "sphere", recursively: true)!
			sphere.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: -1, z: 0, duration: 1)))
			
			contentView = sceneView
		}
		else {
			contentView = NormalView(frame: viewRect)
		}

		contentView.wantsLayer = false
//		if forScene {
//			if let layer = contentView.layer {
//				let mask = CALayer()
//				mask.bounds = layer.bounds
//				mask.anchorPoint = layer.anchorPoint
//				mask.position = layer.position
//				layer.masksToBounds = true
//				layer.mask = mask
//			}
//		}

		window.contentView = contentView

#if false
		window.backgroundColor = .systemYellow.withAlphaComponent(0.5)
#else
		window.backgroundColor = .clear
#endif
		
		return window
	}


	private func configureImageWindow() -> NSWindow? {
		guard let screen = NSScreen.screens.first else { return nil }
		
		let contentRect = CGRect(x: screen.frame.midX - 400, y: screen.frame.midY - 150, width: 400, height: 300)
		
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
		let contentView = ImageView(frame: viewRect)
		contentView.imageAlignment = .alignCenter
		contentView.image = NSImage(named: "xray")
		contentView.wantsLayer = false

//		if let layer = contentView.layer {
//			let mask = CALayer()
//			mask.bounds = layer.bounds
//			mask.anchorPoint = layer.anchorPoint
//			mask.position = layer.position
//			mask.contents = contentView.image
//			layer.masksToBounds = true
//			layer.mask = mask
//		}

		window.contentView = contentView

		window.backgroundColor = .clear
//		window.alphaValue = 0.25
		window.alphaValue = 0.05

		return window
	}
	
}

var lastTime: TimeInterval = 0

extension ViewController: SCNSceneRendererDelegate {
	
	func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		if time - lastTime > 0.25 {
			DispatchQueue.main.async {
				if let sceneView = self.sceneWindow.contentView as? SceneView {
					//debugLog("creating image...")
					let image = sceneView.snapshot() //.cgImage(forProposedRect: nil, context: nil, hints: nil)
					//debugLog("updating window...")
					if let imageView = self.imageWindow.contentView as? ImageView {
						imageView.image = image
					}
//					CATransaction.begin()
//					CATransaction.setDisableActions(true)
//					sceneView.layer?.mask?.contents = image
//					CATransaction.commit()
				}
			}
			lastTime = time
		}
	}

}
