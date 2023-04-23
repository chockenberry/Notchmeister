//
//  GameViewController.swift
//  SceneTest
//
//  Created by Craig Hockenberry on 4/16/23.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
	var scene = SCNScene(named: "art.scnassets/ship.scn")!
	
	// Apple's silicon expertise is not only on the die, but also on the dice.
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		// create and position a camera for the scene
		setupCamera()
        
        // create and add a light to the scene
		setupLights()
		
		// setup the scene objects
		setupObjects()
		
		setupViewScene()
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
			let node = hitResults.first!.node
#if true
			let dieScene1 = scene.rootNode.childNode(withName: "die1", recursively: true)!
			let die1 = dieScene1.childNode(withName: "D6", recursively: true)!
			//die1.worldPosition = SCNVector3(-length, length, 0)
			if node == die1 {
				let spin1 = CGFloat.random(in: 4.0 ... 8.0)
				die1.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin1), at: SCNVector3(x: 1.0, y: 1.0, z: 0.0), asImpulse: true)
			}
			
			let dieScene2 = scene.rootNode.childNode(withName: "die2", recursively: true)!
			let die2 = dieScene2.childNode(withName: "D6", recursively: true)!
			//die2.worldPosition = SCNVector3(length, length, 0)
			if node == die2 {
				let spin2 = CGFloat.random(in: -8.0 ... -4.0)
				die2.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin2), at: SCNVector3(x: 1.0, y: 1.0, z: 0.0), asImpulse: true)
			}
#else
            // retrieved the first clicked object
            let result = hitResults[0]
            
			result.node.physicsBody?.applyForce(SCNVector3(-5, 0, 0), at: SCNVector3(x: 0.5, y: 0.5, z: 0.1), asImpulse: true)
//			result.node.physicsBody?.applyForce(SCNVector3(-100, 0, 0), at: SCNVector3(0, 0, 0), asImpulse: true)

            // get its material
            let material = result.node.geometry!.firstMaterial!
			let originalColor = material.emission.contents
			
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = originalColor
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
#endif
        }
    }
	
	var scnView: SCNView!
	var scnScene: SCNScene!
	var theRing: SCNNode!

	func setupCamera() {
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
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
	
	let length = 3

	func setupObjects() {
		let anchor = scene.rootNode.childNode(withName: "anchor", recursively: true)!
		anchor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
		//anchor.physicsBody?.mass = 5.0
		anchor.physicsBody?.categoryBitMask = 1
		anchor.physicsBody?.collisionBitMask = 0
		anchor.isHidden = false
		anchor.worldPosition = SCNVector3(0, length, 0)
		anchor.physicsBody?.isAffectedByGravity = false

		let dieScene1 = scene.rootNode.childNode(withName: "die1", recursively: true)!
		let die1 = dieScene1.childNode(withName: "D6", recursively: true)!
		die1.worldPosition = SCNVector3(-length, length, 0)
		/*
		let joint1 = SCNPhysicsBallSocketJoint(body: die1.physicsBody!, anchor: SCNVector3(x: CGFloat(length), y: 0, z: 0))
		scene.physicsWorld.addBehavior(joint1)
		let spin1 = CGFloat.random(in: -4.0...4.0)
		die1.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin1), at: SCNVector3(x: 0.0, y: 1.0, z: 0.0), asImpulse: true)
		 */
		setupCord(anchor: anchor, linkCount: 14, die: die1)
		
		let dieScene2 = scene.rootNode.childNode(withName: "die2", recursively: true)!
		let die2 = dieScene2.childNode(withName: "D6", recursively: true)!
		die2.worldPosition = SCNVector3(length, length, 0)
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
					anchorB: SCNVector3Make(0, 0.05, 0)
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
			anchorB: SCNVector3Make(0, 0.1, 0)
		)
		scene.physicsWorld.addBehavior(joint)
		
		for link in links {
			anchor.addChildNode(link)
		}
	}
	
	func setupViewScene() {
		// retrieve the SCNView
		let scnView = self.view as! SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// configure the view
		scnView.backgroundColor = NSColor.black
		
		// Add a click gesture recognizer
		let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
		var gestureRecognizers = scnView.gestureRecognizers
		gestureRecognizers.insert(clickGesture, at: 0)
		scnView.gestureRecognizers = gestureRecognizers

	}

}
