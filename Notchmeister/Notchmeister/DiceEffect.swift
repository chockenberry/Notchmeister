//
//  DiceEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit
import SceneKit

class DiceEffect: NotchEffect {
	
	var hitWindow: NSWindow?
	
	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		debugLog()
		super.init(with: parentLayer, in: parentView, of: parentWindow)
	}
	
	deinit {
		debugLog()
		hitWindow?.orderOut(self)
	}
		
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentWindow else { return }

		debugLog("point = \(point), underNotch = \(underNotch)")

		if hitWindow == nil {
			hitWindow = configureSceneHitWindow()
			let sceneHitView = hitWindow!.contentView as! SceneHitView
			let scene = configureScene()
			if let animationWindow = configureSceneAnimationWindow(using: sceneHitView, scene: scene) {
				hitWindow!.addChildWindow(animationWindow, ordered: .below)
			}
			//hitWindow!.orderFront(self)
			//hitWindow!.orderFrontRegardless()
			hitWindow!.order(.below, relativeTo: parentWindow.windowNumber)
		}
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		//guard let parentLayer = parentLayer else { return }

		do {
			if underNotch {
			}
			else {
			}
		}

	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentView else { return }
		guard let parentWindow else { return }
		guard let hitWindow else { return }
		
		debugLog("point = \(point), underNotch = \(underNotch)")

#if true
		hitWindow.orderOut(self)
		self.hitWindow = nil
#else
		//if let windowPoint = parentView?.convert(point, to: nil) {
			if let animationWindow = hitWindow.childWindows?.first {
				let screenPoint = parentWindow.convertPoint(toScreen: point)
				let hitPoint = hitWindow.convertPoint(fromScreen: screenPoint)
				if let contentView = animationWindow.contentView {
					let animationPoint = contentView.convert(hitPoint, from: nil)
					let contained = contentView.bounds.contains(animationPoint)
					debugLog("animationPoint = \(animationPoint), contained = \(contained)")
					if !contained {
						hitWindow.orderOut(self)
						self.hitWindow = nil
					}
				}
			}
		//}
#endif

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
	
	private let size = CGSize(width: 300, height: 120)
	
	private func configureSceneHitWindow() -> NSWindow? {
		guard let parentWindow else { return nil }
		guard let screen = parentWindow.screen else { return nil }

		//let size = parentWindow.frame.size
		
		let index = (NSScreen.screens.firstIndex(of: screen) ?? Int.min) + 1

		let origin = CGPoint(x: screen.frame.midX - (size.width / 2), y: screen.frame.maxY - size.height)
		
		let contentRect = CGRect(origin: origin, size: size)

		let window = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
		window.canHide = false
		window.isMovable = false
		window.isOpaque = false
		window.hasShadow = false
		window.level = .popUpMenu
		window.collectionBehavior = [.transient, .canJoinAllSpaces]

		let viewRect = CGRect(origin: .zero, size: size)
		let contentView = SceneHitView(frame: viewRect)
		
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
		guard let parentWindow else { return nil }
		guard let screen = parentWindow.screen else { return nil }

		//let size = parentWindow.frame.size

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

		let viewRect = CGRect(origin: .zero, size: size)
		let contentView = SceneAnimationView(frame: viewRect)
		contentView.backgroundColor = .clear

		contentView.scene = scene
			
		contentView.delegate = sceneHitView
			
		contentView.wantsLayer = false
		contentView.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))

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
			
			let ambientLightNode = SCNNode()
			ambientLightNode.light = SCNLight()
			ambientLightNode.light!.type = .ambient
			ambientLightNode.light!.color = NSColor.white
			scene.rootNode.addChildNode(ambientLightNode)
		}

		let anchorY: CGFloat = 2.25
		
		func setupObjects() {
			guard let parentView else { return }
			
			let linkCount: Int
			switch parentView.frame.notchSetting {
			case .largerText:
				linkCount = 13
			case .large:
				linkCount = 14
			case .default:
				linkCount = 15
			case .moreSpace:
				linkCount = 16
			default:
				linkCount = 15
			}
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
			die1.physicsBody?.isAffectedByGravity = true
			die1.worldPosition = SCNVector3Make(-1, anchorY + 1, 0)
			setupCord(anchor: anchor, linkCount: linkCount, die: die1)
			
			let dieReference2 = scene.rootNode.childNode(withName: "die2", recursively: true)!
			let die2 = dieReference2.childNode(withName: "D6", recursively: true)!
			die2.physicsBody?.isAffectedByGravity = true
			die2.worldPosition = SCNVector3(1, anchorY + 1, 0)
			setupCord(anchor: anchor, linkCount: linkCount + 2, die: die2)
		}

		var links: [SCNNode] = []
		
		func setupCord(anchor: SCNNode, linkCount: Int, die: SCNNode) {
			
			func createLink(position: CGFloat) -> SCNNode {
				let geometry = SCNCylinder(radius: 0.025, height: 0.15)
				
				let link = SCNNode(geometry: geometry)
				link.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
				link.physicsBody?.mass = 0.5
				link.physicsBody?.restitution = 0
				link.physicsBody?.damping = 0.5
				link.physicsBody?.categoryBitMask = 1
				link.physicsBody?.collisionBitMask = 0
				link.physicsBody?.friction = 1.0
				link.physicsBody?.velocityFactor = SCNVector3Make(1, 1, 1)
				link.physicsBody?.isAffectedByGravity = true
				
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
						anchorB: SCNVector3Make(0, -0.05, 0)
					)
					scene.physicsWorld.addBehavior(joint)
				}
				else {
					let joint = SCNPhysicsHingeJoint(
						bodyA: link.physicsBody!,
						axisA: SCNVector3Make(0, 1, 0),
						anchorA: SCNVector3Make(0, -0.05, 0),
						bodyB: previousLink.physicsBody!,
						axisB: SCNVector3Make(0, 1, 0),
						anchorB: SCNVector3Make(0, +0.05, 0)
					)
					scene.physicsWorld.addBehavior(joint)
				}
				previousLink = link
				linkIndex += 1
			}

			let joint = SCNPhysicsBallSocketJoint(
				bodyA: die.physicsBody!,
				anchorA: SCNVector3Make(0.45, 0.45, 0.45),
				bodyB: previousLink.physicsBody!,
				anchorB: SCNVector3Make(0, +0.05, 0)
			)
			scene.physicsWorld.addBehavior(joint)
			
			for link in links {
				anchor.addChildNode(link)
			}
		}

		let scene = SCNScene(named: "dice.scnassets/notch.scn")!

		setupCamera()
		setupLights()
		setupObjects()

		return scene
	}
}

