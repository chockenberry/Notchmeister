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
		imageWindow.addChildWindow(sceneWindow, ordered: .below)
		
		normalWindow = configureWindow(forScene: false)
		
		NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil) { notification in
			if let window = NSApplication.shared.windows.first, let screen = window.screen {
				debugLog("space changed: screen = \(screen.frame)")
			}
		}
	}

	override func viewWillLayout() {
		super.viewWillLayout()

//		sceneWindow.orderFront(self)
//		imageWindow.order(.above, relativeTo: sceneWindow.windowNumber)
		imageWindow.orderFront(self)
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
			
			let node = scene.rootNode.childNode(withName: "box", recursively: true)!
			node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: -1, z: 0, duration: 1)))
			
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
//		window.alphaValue = 1.0
		window.alphaValue = 0.5
//		window.alphaValue = 0.05

		return window
	}
	
}

var lastTime: TimeInterval = 0

extension ViewController: SCNSceneRendererDelegate {
	
	func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		if time - lastTime > 0.01 {
			let rootNode = scene.rootNode
			let boxNode = scene.rootNode.childNode(withName: "box", recursively: true)!
			let node = boxNode.childNode(withName: "cylinder", recursively: true)!
			
			let (min, max) = node.boundingBox

			let bottomLeftBack = SCNVector3(min.x, min.y, max.z)
			let topRightBack = SCNVector3(max.x, max.y, max.z)
			let topLeftBack = SCNVector3(min.x, max.y, max.z)
			let bottomRightBack = SCNVector3(max.x, min.y, max.z)

			let bottomLeftFront = SCNVector3(min.x, min.y, min.z)
			let topRightFront = SCNVector3(max.x, max.y, min.z)
			let topLeftFront = SCNVector3(min.x, max.y, min.z)
			let bottomRightFront = SCNVector3(max.x, min.y, min.z)

			let destination = rootNode

			var paths: [NSBezierPath] = []
			
			paths.append(pathForBoundingPoints([bottomLeftFront, bottomRightFront, topRightFront, topLeftFront], of: node, with: destination, in: renderer))
			paths.append(pathForBoundingPoints([bottomLeftBack, bottomRightBack, topRightBack, topLeftBack], of: node, with: destination, in: renderer))
			paths.append(pathForBoundingPoints([bottomLeftBack, bottomLeftFront, topLeftFront, topLeftBack], of: node, with: destination, in: renderer))
			paths.append(pathForBoundingPoints([bottomRightBack, bottomRightFront, topRightFront, topRightBack], of: node, with: destination, in: renderer))
			paths.append(pathForBoundingPoints([topLeftBack, topLeftFront, topRightFront, topRightBack], of: node, with: destination, in: renderer))
			paths.append(pathForBoundingPoints([bottomLeftBack, bottomLeftFront, bottomRightFront, bottomRightBack], of: node, with: destination, in: renderer))
					
			DispatchQueue.main.async {
				//if let sceneView = self.sceneWindow.contentView as? SceneView {
					//debugLog("creating image...")
					//let image = sceneView.snapshot() //.cgImage(forProposedRect: nil, context: nil, hints: nil)
					if let imageView = self.imageWindow.contentView as? ImageView {
						imageView.paths = paths
					}
				//}
			}
			lastTime = time
		}
	}

	func pathForBoundingPoints(_ boundingPoints: [SCNVector3], of node: SCNNode, with destination: SCNNode, in renderer: SCNSceneRenderer) -> NSBezierPath {
		let path = NSBezierPath()

		var firstPoint = true
		for boundingPoint in boundingPoints {
			let worldPoint = node.convertPosition(boundingPoint, to: destination)
			let projectedPoint = renderer.projectPoint(worldPoint)
			let point = CGPoint(x: projectedPoint.x, y: projectedPoint.y)
			if firstPoint {
				path.move(to: point)
			}
			else {
				path.line(to: point)
			}
			firstPoint = false
		}
		path.close()
		
		return path
	}

}
