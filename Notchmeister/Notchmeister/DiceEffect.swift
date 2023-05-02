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

	var hitWindow: NSWindow!
	
	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		//self.edgeLayer = CAShapeLayer.notchOutlineLayer(for: parentLayer.bounds.size, flipped: true)

		super.init(with: parentLayer, in: parentView, of: parentWindow)
		

		//configureSublayers()
		//self.perform(#selector(configureChildWindow), with: nil, afterDelay: 2.0)
		//configureChildWindow()
		
		hitWindow = configureSceneHitWindow()
		let sceneHitView = hitWindow.contentView as! SceneHitView
		let scene = configureScene()
		if let animationWindow = configureSceneAnimationWindow(using: sceneHitView, scene: scene) {
			hitWindow.addChildWindow(animationWindow, ordered: .below)
		}
		hitWindow.orderFront(self)

	}
	
	deinit {
		hitWindow.orderOut(self)
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
	
	private let size = CGSize(width: 300, height: 100)
	private let viewScale: CGFloat = 1
	
	private func configureSceneHitWindow() -> NSWindow? {
		guard let screen = parentWindow?.screen else { return nil }

		let index = (NSScreen.screens.firstIndex(of: screen) ?? Int.min) + 1

		let origin = CGPoint(x: screen.frame.midX - (size.width / 2), y: screen.frame.maxY - size.height)
		
		let contentRect = CGRect(origin: origin, size: size)
//		let contentRect = CGRect(x: screen.frame.minX, y: screen.frame.minY, width: 400, height: 300)
//		let contentRect = CGRect(x: 0, y: 0, width: 400, height: 300)

		let window = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
		window.canHide = false
		window.isMovable = false
		window.isOpaque = false
		window.hasShadow = false
		window.level = .popUpMenu
		window.collectionBehavior = [.transient, .canJoinAllSpaces]

		let viewRect = CGRect(origin: .zero, size: size)
		let contentView = SceneHitView(frame: viewRect)
		//contentView.imageAlignment = .alignCenter
		//contentView.image = NSImage(named: "xray")
		contentView.wantsLayer = false
		contentView.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width / viewScale, height: size.height / viewScale))
		//contentView.layerContentsRedrawPolicy = .onSetNeedsDisplay

		
		window.title = "Dice Hit Window \(index)"
		window.contentView = contentView

#if false
		if Defaults.shouldDebugDrawing {
			window.backgroundColor = NSColor.systemYellow
		}
		else {
			window.backgroundColor = .clear
		}
#else
		window.backgroundColor = .clear
#endif
		
		window.alphaValue = 1.0
//		window.alphaValue = 0.05

		return window
	}

	private func configureSceneAnimationWindow(using sceneHitView: SceneHitView, scene: SCNScene) -> NSWindow? {
		guard let screen = parentWindow?.screen else { return nil }

		let index = (NSScreen.screens.firstIndex(of: screen) ?? Int.min) + 1

		let origin = CGPoint(x: screen.frame.midX - (size.width / 2), y: screen.frame.maxY - size.height)
		
		let contentRect = CGRect(origin: origin, size: size)

		let window = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
		window.ignoresMouseEvents = true
		window.canHide = false
		window.isMovable = false
		window.isOpaque = false
		window.hasShadow = false
		window.level = .popUpMenu

		//let viewRect = CGRect(x: 0, y: 0, width: 400, height: 300)
		let viewRect = CGRect(origin: .zero, size: size)
		let contentView = SceneView(frame: viewRect)
		contentView.backgroundColor = .clear

		contentView.scene = scene
			
		contentView.delegate = sceneHitView
			
		contentView.wantsLayer = false
		contentView.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width / viewScale, height: size.height / viewScale))

		window.title = "Dice Animation Window \(index)"
		window.contentView = contentView

#if true
		if Defaults.shouldDebugDrawing {
			window.backgroundColor = NSColor.systemYellow.withAlphaComponent(0.25)
		}
		else {
			window.backgroundColor = .clear
		}
#else
		window.backgroundColor = .clear
#endif

		return window
	}
	
	func configureScene() -> SCNScene {
		
		func setupCamera() {
			let cameraNode = SCNNode()
			cameraNode.camera = SCNCamera()
			scene.rootNode.addChildNode(cameraNode)
			
			cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
			cameraNode.camera?.projectionDirection = .horizontal
			cameraNode.camera?.fieldOfView = 20
		}

		func setupLights() {
			let lightNode = SCNNode()
			lightNode.light = SCNLight()
			lightNode.light!.type = .omni
			lightNode.light!.color = NSColor.systemOrange
			lightNode.position = SCNVector3(x: 0, y: 0, z: 15)
			scene.rootNode.addChildNode(lightNode)
			
			// create and add an ambient light to the scene
			let ambientLightNode = SCNNode()
			ambientLightNode.light = SCNLight()
			ambientLightNode.light!.type = .ambient
			ambientLightNode.light!.color = NSColor.white
			scene.rootNode.addChildNode(ambientLightNode)
		}

		let anchorY: CGFloat = 2
		let length = 1
		let scale: CGFloat = 1
		
		func setupObjects() {
			//scene.rootNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
			
			let anchor = scene.rootNode.childNode(withName: "anchor", recursively: true)!
			anchor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
			//anchor.physicsBody?.mass = 5.0
			anchor.physicsBody?.categoryBitMask = 1
			anchor.physicsBody?.collisionBitMask = 0
			anchor.isHidden = false
			anchor.worldPosition = SCNVector3Make(0, anchorY, 0)
			anchor.physicsBody?.isAffectedByGravity = false

			let dieReference1 = scene.rootNode.childNode(withName: "die1", recursively: true)!
			let die1 = dieReference1.childNode(withName: "D6", recursively: true)!
			die1.scale = SCNVector3Make(scale, scale, scale)
			if var options = die1.physicsBody?.physicsShape?.options {
				options[.scale] = scale
				let physicsShape = SCNPhysicsShape(node: die1, options: options)
				//let physicsShape = SCNPhysicsBody(type: .dynamic, shape: .none)
				die1.physicsBody?.physicsShape = physicsShape
			}
			die1.worldPosition = SCNVector3Make(-1, anchorY + 1, 0)
			/*
			let joint1 = SCNPhysicsBallSocketJoint(body: die1.physicsBody!, anchor: SCNVector3(x: CGFloat(length), y: 0, z: 0))
			scene.physicsWorld.addBehavior(joint1)
			let spin1 = CGFloat.random(in: -4.0...4.0)
			die1.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin1), at: SCNVector3(x: 0.0, y: 1.0, z: 0.0), asImpulse: true)
			 */
			setupCord(anchor: anchor, linkCount: 14, die: die1)
			
			let dieReference2 = scene.rootNode.childNode(withName: "die2", recursively: true)!
			let die2 = dieReference2.childNode(withName: "D6", recursively: true)!
			die2.scale = SCNVector3Make(scale, scale, scale)
			if var options = die2.physicsBody?.physicsShape?.options {
				options[.scale] = scale
				let physicsShape = SCNPhysicsShape(node: die2, options: options)
				//let physicsShape = SCNPhysicsBody(type: .dynamic, shape: .none)
				die2.physicsBody?.physicsShape = physicsShape
			}
			die2.worldPosition = SCNVector3(1, anchorY + 1, 0)
			/*
			let joint2 = SCNPhysicsBallSocketJoint(body: die2.physicsBody!, anchor: SCNVector3(-length, 0, 0))
			scene.physicsWorld.addBehavior(joint2)
			let spin2 = CGFloat.random(in: -4.0...4.0)
			die2.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin2), at: SCNVector3(x: 0.0, y: 1.0, z: 0.0), asImpulse: true)
			 */
			setupCord(anchor: anchor, linkCount: 16, die: die2)
		}

		var links: [SCNNode] = []
		
		func setupCord(anchor: SCNNode, linkCount: Int, die: SCNNode) {
			
			func createLink(position: CGFloat) -> SCNNode {
				//var geometry:SCNGeometry
				//var link:SCNNode
				
				//let geometry = SCNSphere(radius: 1)
				let geometry = SCNCylinder(radius: 0.025, height: 0.15)
				//geometry.materials.first?.diffuse.contents = NSColor.red
				
				let link = SCNNode(geometry: geometry)
				link.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
				link.physicsBody?.mass = 0.5
				link.physicsBody?.restitution = 0
				link.physicsBody?.damping = 0.5
				link.physicsBody?.categoryBitMask = 1
				link.physicsBody?.collisionBitMask = 0
				link.physicsBody?.friction = 1.0
				link.physicsBody?.velocityFactor = SCNVector3Make(1, 1, 1)
				link.scale = SCNVector3Make(scale, scale, scale)
				
				let cycleDuration: TimeInterval = 0.5
				let changeColor = SCNAction.customAction(duration: cycleDuration) { node, elapsedTime in
					let offset = (cycleDuration * position)
					let normalized = sin((.pi * 4) * ((elapsedTime / cycleDuration) - offset))
					//debugLog("\(elapsedTime) -> \(normalized)")
	//				let color = NSColor(red: normalized / 2, green: normalized / 4, blue: normalized, alpha: 1) // purple
					let color = NSColor(red: normalized / 2 + 0.5, green: normalized / 4 + 0.25, blue: 0.5, alpha: 1)
					node.geometry?.firstMaterial?.diffuse.contents = color
				}
				link.runAction(SCNAction.repeatForever(changeColor))
				
				return link
			}

			var previousLink = anchor
			var linkIndex = 0
			while linkIndex < linkCount {
				let link = createLink(position: CGFloat(linkIndex) / CGFloat(linkCount))
				links.append(link)
				if linkIndex == 0 {
					let joint = SCNPhysicsBallSocketJoint(
						bodyA: anchor.physicsBody!,
						anchorA: SCNVector3Make(0, 0, 0),
						bodyB: link.physicsBody!,
						anchorB: SCNVector3Make(0, -(0.05 * scale), 0)
					)
					scene.physicsWorld.addBehavior(joint)
				}
				else {
					let joint = SCNPhysicsHingeJoint(
						bodyA: link.physicsBody!,
						axisA: SCNVector3Make(0, 1, 0),
						anchorA: SCNVector3Make(0, -(0.05 * scale), 0),
						bodyB: previousLink.physicsBody!,
						axisB: SCNVector3Make(0, 1, 0),
						anchorB: SCNVector3Make(0, (0.05 * scale), 0)
					)
					scene.physicsWorld.addBehavior(joint)
				}
				previousLink = link
				linkIndex += 1
			}

			let joint = SCNPhysicsBallSocketJoint(
				bodyA: die.physicsBody!,
				anchorA: SCNVector3Make(0.45 * scale, 0.45 * scale, 0.45 * scale),
				bodyB: previousLink.physicsBody!,
				anchorB: SCNVector3Make(0, (0.05 * scale), 0)
			)
			scene.physicsWorld.addBehavior(joint)
			
			for link in links {
				anchor.addChildNode(link)
			}
		}

		let scene = SCNScene(named: "dice.scnassets/notch.scn")!
		//scene.rootNode.scale = SCNVector3Make(0.5, 0.5, 0.5)

		setupCamera()
		setupLights()
		setupObjects()

		return scene
	}
}

