//
//  GameViewController.swift
//  SceneTest
//
//  Created by Craig Hockenberry on 4/16/23.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
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
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let box1 = scene.rootNode.childNode(withName: "box1", recursively: true)!
		let box2 = scene.rootNode.childNode(withName: "box2", recursively: true)!
		let anchor = scene.rootNode.childNode(withName: "anchor", recursively: true)!

//		let joint = SCNPhysicsHingeJoint(body: box.physicsBody!, axis: SCNVector3(1, 1, 1), anchor: SCNVector3(0, 5, 0))
//		let joint = SCNPhysicsSliderJoint(body: box.physicsBody!, axis: SCNVector3(1, 1, 1), anchor: SCNVector3(0, 5, 0))
		let joint1 = SCNPhysicsBallSocketJoint(body: box1.physicsBody!, anchor: SCNVector3(5, 0, 0))
		scene.physicsWorld.addBehavior(joint1)
		let joint2 = SCNPhysicsBallSocketJoint(body: box2.physicsBody!, anchor: SCNVector3(-5, 0, 0))
		scene.physicsWorld.addBehavior(joint2)

		box1.position = SCNVector3(0, 5, 0)
		box2.position = SCNVector3(0, 5, 0)
		
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
            // retrieved the first clicked object
            let result = hitResults[0]
            
			result.node.physicsBody?.applyForce(SCNVector3(-2, 0, 0), at: SCNVector3(x: 0.5, y: 0.25, z: 0.1), asImpulse: true)
//			result.node.physicsBody?.applyForce(SCNVector3(-100, 0, 0), at: SCNVector3(0, 0, 0), asImpulse: true)

//			result.node.position = SCNVector3(0, 5, 0)

            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
