//
//  GameViewController.swift
//  SceneTest
//
//  Created by Craig Hockenberry on 4/16/23.
//

import SceneKit
import QuartzCore

let length = 3

class GameViewController: NSViewController {
    
	var scene = SCNScene(named: "art.scnassets/ship.scn")!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
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
        
        // retrieve the ship node
#if false
        let box1 = scene.rootNode.childNode(withName: "box1", recursively: true)!
		let box2 = scene.rootNode.childNode(withName: "box2", recursively: true)!

//		let joint = SCNPhysicsHingeJoint(body: box.physicsBody!, axis: SCNVector3(1, 1, 1), anchor: SCNVector3(0, 5, 0))
//		let joint = SCNPhysicsSliderJoint(body: box.physicsBody!, axis: SCNVector3(1, 1, 1), anchor: SCNVector3(0, 5, 0))
		let joint1 = SCNPhysicsBallSocketJoint(body: box1.physicsBody!, anchor: SCNVector3(2, 0, 0))
		scene.physicsWorld.addBehavior(joint1)
		let joint2 = SCNPhysicsBallSocketJoint(body: box2.physicsBody!, anchor: SCNVector3(-2, 0, 0))
		scene.physicsWorld.addBehavior(joint2)

		box1.position = SCNVector3(0, 5, 0)
		box2.position = SCNVector3(0, 5, 0)
#else

		let anchor = scene.rootNode.childNode(withName: "anchor", recursively: true)!
		anchor.isHidden = false
		anchor.worldPosition = SCNVector3(0, length, 0)
		
		let dieScene1 = scene.rootNode.childNode(withName: "die1", recursively: true)!
		let die1 = dieScene1.childNode(withName: "D6", recursively: true)!
		//die1.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.0)
		//die1.rotation = SCNVector4(x: .pi/4, y: .pi/4, z: 0, w: 0)
		//die1.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0)
		//die1.physicsBody!.centerOfMassOffset = SCNVector3(0.5, 0.5, 0.5)
		//die1.localTranslate(by: SCNVector3(x: 0.5, y: 0.5, z: 0.5))
		die1.worldPosition = SCNVector3(-length, length, 0)
		let joint1 = SCNPhysicsBallSocketJoint(body: die1.physicsBody!, anchor: SCNVector3(x: CGFloat(length), y: 0, z: 0))
		//let joint1 = SCNPhysicsBallSocketJoint(bodyA: die1.physicsBody!, anchorA: SCNVector3(x: CGFloat(length) + 0.5, y: 0.5, z: 0.5), bodyB: anchor.physicsBody!, anchorB: SCNVector3())
		scene.physicsWorld.addBehavior(joint1)
		let spin1 = CGFloat.random(in: -4.0...4.0)
		die1.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin1), at: SCNVector3(x: 0.0, y: 1.0, z: 0.0), asImpulse: true)

//		let box2 = scene.rootNode.childNode(withName: "box2", recursively: true)!
		let dieScene2 = scene.rootNode.childNode(withName: "die2", recursively: true)!
		let die2 = dieScene2.childNode(withName: "D6", recursively: true)!
		//die2.physicsBody!.centerOfMassOffset = SCNVector3(0.5, 0.5, 0.5)
		//die2.localTranslate(by: SCNVector3(x: 0.5, y: 0.5, z: 0.5))
		die2.worldPosition = SCNVector3(length, length, 0)
		let joint2 = SCNPhysicsBallSocketJoint(body: die2.physicsBody!, anchor: SCNVector3(-length, 0, 0))
		scene.physicsWorld.addBehavior(joint2)
		let spin2 = CGFloat.random(in: -4.0...4.0)
		die2.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin2), at: SCNVector3(x: 0.0, y: 1.0, z: 0.0), asImpulse: true)
		//die2.physicsBody?.applyForce(SCNVector3(0, 1, 0), at: SCNVector3(x: 0.0, y: -0.25, z: 0.1), asImpulse: true)

//		die1.worldPosition = SCNVector3(-2, 2, 0)
//		die2.worldPosition = SCNVector3(2, 2, 0)
//		box2.position = SCNVector3(0, 5, 0)
		
//		dieScene1.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 1)))
#endif
		
        // animate the 3d object
		//box.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
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
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
#if true
			let dieScene1 = scene.rootNode.childNode(withName: "die1", recursively: true)!
			let die1 = dieScene1.childNode(withName: "D6", recursively: true)!
			die1.worldPosition = SCNVector3(-length, length, 0)
			let spin1 = CGFloat.random(in: -4.0...4.0)
			die1.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin1), at: SCNVector3(x: 0.0, y: 1.0, z: 0.0), asImpulse: true)

			let dieScene2 = scene.rootNode.childNode(withName: "die2", recursively: true)!
			let die2 = dieScene2.childNode(withName: "D6", recursively: true)!
			die2.worldPosition = SCNVector3(length, length, 0)
			let spin2 = CGFloat.random(in: -4.0...4.0)
			die2.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: spin2), at: SCNVector3(x: 0.0, y: 1.0, z: 0.0), asImpulse: true)
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
}
