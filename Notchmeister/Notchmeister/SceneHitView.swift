//
//  SceneHitView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

import SceneKit

class SceneHitView: NSView {
	
	var paths: [NSBezierPath] {
		didSet {
			needsDisplay = true
			//layer?.needsDisplay()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
		
	override init(frame frameRect: NSRect) {
		debugLog()
		paths = []
		super.init(frame: frameRect)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		//debugLog()
		NSColor.clear.set()
		dirtyRect.fill()

		NSColor.systemPurple.setFill()
		for path in paths {
			path.fill()
		}
	
#if true
		if Defaults.shouldDebugDrawing {
			layer?.opacity = 0.5
		}
		else {
			layer?.opacity = 0.01
		}
#else
		layer?.opacity = 0.5
#endif
	}
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		debugLog()
		return true
	}
	
	override func mouseDown(with event: NSEvent) {
		debugLog()
	}
	
	override var layerContentsRedrawPolicy: NSView.LayerContentsRedrawPolicy {
		get {
			return .onSetNeedsDisplay
		}
		set {
			// ignored
		}
	}
	
	override var wantsLayer: Bool {
		get {
			return false
		}
		set {
			// ignored
		}
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		debugLog("point = \(point)")
		return super.hitTest(point)
	}
	
}

var lastTime: TimeInterval = 0

var lastWorld: SCNVector3 = SCNVector3Zero

extension SCNVector3 {

	public func moved(from: SCNVector3, delta: CGFloat = 0.01) -> Bool {
		let deltaX = abs(x - from.x)
		let deltaY = abs(y - from.y)
		let deltaZ = abs(z - from.z)

		return (deltaX > delta) || (deltaY > delta) || (deltaZ > delta)
	}

}

extension SceneHitView: SCNSceneRendererDelegate {
	
	func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		if time - lastTime > 0.2 {
			//debugLog()
			DispatchQueue.main.async { [self] in
				let rootNode = scene.rootNode
				let dieScene1 = rootNode.childNode(withName: "die1", recursively: true)!
				let node = dieScene1.childNode(withName: "D6", recursively: true)!

				let destination: SCNNode? = rootNode
				
				node.transform = node.presentation.transform

				let world = node.convertPosition(SCNVector3Zero, to: destination)
				if !world.moved(from: lastWorld, delta: 0.01) {
					debugLog("no change")
					return
				}
				lastWorld = world
				let projectedWorldPoint = renderer.projectPoint(world)
				let worldPoint = CGPoint(x: projectedWorldPoint.x, y: projectedWorldPoint.y)
				debugLog("worldPoint = \(worldPoint)")

				let (min, max) = node.boundingBox
				let projectedMinPoint = renderer.projectPoint(min)
				let minPoint = CGPoint(x: projectedMinPoint.x, y: projectedMinPoint.y)
				let projectedMaxPoint = renderer.projectPoint(max)
				let maxPoint = CGPoint(x: projectedMaxPoint.x, y: projectedMaxPoint.y)
				debugLog("minPoint = \(minPoint), maxPoint = \(maxPoint), width = \(maxPoint.x - minPoint.x), height = \(maxPoint.y - minPoint.y)")

				let bottomLeftBack = SCNVector3(min.x, min.y, max.z)
				let topRightBack = SCNVector3(max.x, max.y, max.z)
				let topLeftBack = SCNVector3(min.x, max.y, max.z)
				let bottomRightBack = SCNVector3(max.x, min.y, max.z)
				
				let bottomLeftFront = SCNVector3(min.x, min.y, min.z)
				let topRightFront = SCNVector3(max.x, max.y, min.z)
				let topLeftFront = SCNVector3(min.x, max.y, min.z)
				let bottomRightFront = SCNVector3(max.x, min.y, min.z)
				
				
				var newPaths: [NSBezierPath] = []
				
				newPaths.append(pathForBoundingPoints([bottomLeftFront, bottomRightFront, topRightFront, topLeftFront], of: node, with: destination, in: renderer))
				newPaths.append(pathForBoundingPoints([bottomLeftBack, bottomRightBack, topRightBack, topLeftBack], of: node, with: destination, in: renderer))
				newPaths.append(pathForBoundingPoints([bottomLeftBack, bottomLeftFront, topLeftFront, topLeftBack], of: node, with: destination, in: renderer))
				newPaths.append(pathForBoundingPoints([bottomRightBack, bottomRightFront, topRightFront, topRightBack], of: node, with: destination, in: renderer))
				newPaths.append(pathForBoundingPoints([topLeftBack, topLeftFront, topRightFront, topRightBack], of: node, with: destination, in: renderer))
				newPaths.append(pathForBoundingPoints([bottomLeftBack, bottomLeftFront, bottomRightFront, bottomRightBack], of: node, with: destination, in: renderer))
				
				self.paths = newPaths
			}
			
			lastTime = time
		}
	}
	
	func pathForBoundingPoints(_ boundingPoints: [SCNVector3], of node: SCNNode, with destination: SCNNode?, in renderer: SCNSceneRenderer) -> NSBezierPath {
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
