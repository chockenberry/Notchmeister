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

		sceneWindow = configureWindow(forScene: true)
		sceneWindow.ignoresMouseEvents = true

		imageWindow = configureImageWindow()
		sceneWindow.addChildWindow(imageWindow, ordered: .above)
		
		normalWindow = configureWindow(forScene: false)
		
		NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { notification in
			if let window = NSApplication.shared.windows.first, let screen = window.screen {
				debugLog("space changed: screen = \(screen.frame)")
			}
		}
	}

	override func viewWillLayout() {
		super.viewWillLayout()

		sceneWindow.orderFront(self)
		imageWindow.order(.above, relativeTo: sceneWindow.windowNumber)
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
		window.canHide = false
		window.isMovable = false
		window.isOpaque = false
		window.hasShadow = false
		window.level = .popUpMenu

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

//			let shapeLayer = CAShapeLayer()
//			shapeLayer.frame = contentView.frame
//
//			let path = CGMutablePath()
//			path.addEllipse(in: CGRect(x: shapeLayer.frame.midX - 110, y: shapeLayer.frame.midY - 110, width: 220, height: 220))
//
//			shapeLayer.path = path
//			shapeLayer.fillColor = NSColor.white.cgColor
//
//			contentView.layer?.mask = shapeLayer
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

	private func configureImageWindow() -> NSWindow? {
		guard let screen = NSScreen.screens.first else { return nil }
		
		let contentRect = CGRect(x: screen.frame.midX - 400, y: screen.frame.midY - 150, width: 400, height: 300)
		
		let window = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
		window.canHide = false
		window.isMovable = false
		window.isOpaque = false
		window.hasShadow = false
		window.level = .popUpMenu
		
		let viewRect = CGRect(x: 0, y: 0, width: 400, height: 300)
		let contentView = ImageView(frame: viewRect)
		contentView.imageAlignment = .alignCenter
		contentView.image = NSImage(named: "xray")
		contentView.wantsLayer = false

		window.contentView = contentView

		window.backgroundColor = .clear
		window.alphaValue = 1.0
//		window.alphaValue = 0.05

		return window
	}
	
}

var lastTime: TimeInterval = 0

extension ViewController: SCNSceneRendererDelegate {
	
	func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		if time - lastTime > 0.25 {
			let rootNode = scene.rootNode
			let sphere = scene.rootNode.childNode(withName: "sphere", recursively: true)!
			let camera = scene.rootNode.childNode(withName: "camera", recursively: true)!
#if false
			let (center, radius) = sphere.boundingSphere

			let destination = rootNode
			
			let worldCenter = sphere.convertPosition(center, to: destination)
			debugLog("worldCenter = \(worldCenter), radius = \(radius)")
#else
			let (min, max) = sphere.boundingBox

	
			let bottomLeft = SCNVector3(min.x, min.y, 0)
			let topRight = SCNVector3(max.x, max.y, 0)
			let topLeft = SCNVector3(min.x, max.y, 0)
			let bottomRight = SCNVector3(max.x, min.y, 0)
	
			let destination = rootNode
			
			let worldBottomLeft = sphere.convertPosition(bottomLeft, to: destination)
			let worldTopRight = sphere.convertPosition(topRight, to: destination)

			let worldTopLeft = sphere.convertPosition(topLeft, to: destination)
			let worldBottomRight = sphere.convertPosition(bottomRight, to: destination)
			
			//debugLog("worldTopRight = \(worldTopRight), projected = \(renderer.projectPoint(worldTopRight))")
			let projectedPoint = renderer.projectPoint(worldTopRight)
			let point = CGPoint(x: projectedPoint.x, y: projectedPoint.y)
#endif
			DispatchQueue.main.async {
				if let sceneView = self.sceneWindow.contentView as? SceneView {
					//debugLog("creating image...")
					let image = sceneView.snapshot() //.cgImage(forProposedRect: nil, context: nil, hints: nil)
					//debugLog("updating window...")
					if let imageView = self.imageWindow.contentView as? ImageView {
						imageView.image = image
						imageView.boundingRect = NSRect(origin: point, size: CGSize(width: 20, height: 20))
//						imageView.layer?.opacity = 0.01
					}
				}
			}
			lastTime = time
		}
	}

}
