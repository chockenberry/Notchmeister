//
//  SceneHitView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 4/23/23.
//

import AppKit

import SceneKit

struct SceneHitTarget {
	let center: CGPoint
	let radius: CGFloat
}

class SceneHitView: NSView {
	
	var targetLayers: [CAShapeLayer] = []
	
	var targets: [SceneHitTarget] {
		didSet {
			if targets.count != targetLayers.count {
				for targetLayer in targetLayers {
					targetLayer.removeFromSuperlayer()
				}

				let fillColor: NSColor
				if Defaults.shouldDebugDrawing {
					fillColor = NSColor.systemPurple.withAlphaComponent(0.5)
				}
				else {
					fillColor = NSColor.systemPurple.withAlphaComponent(0.01)
				}

				for target in targets {
					let path = CGMutablePath()
					path.addArc(center: .zero, radius: target.radius, startAngle: 0, endAngle: (.pi * 2), clockwise: true)
					let shapeLayer = CAShapeLayer()
					shapeLayer.path = path
					shapeLayer.fillColor = fillColor.cgColor
					layer?.addSublayer(shapeLayer)
					targetLayers.append(shapeLayer)
				}
			}
			needsDisplay = true
		}
	}

	weak var parentWindow: NSWindow?
	
	var lastTime: TimeInterval = 0

	var lastTargetCenter1: CGPoint = .zero
	var lastTargetCenter2: CGPoint = .zero

	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}
		
	override init(frame frameRect: NSRect) {
		debugLog()
		targets = []
		super.init(frame: frameRect)
	}
	
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		debugLog()
		return true
	}
	
	override func mouseDown(with event: NSEvent) {
		debugLog()
#if true
		if let parentWindow {
			window?.order(.below, relativeTo: parentWindow.windowNumber)
			debugLog("reordered hitWindow")
		}
#else
		if parentWindow != nil {
			// NOTE: This reordering keeps the NotchWindow, and its TrackingView, above the hitWindow (and this view).
			// This is needed to keep the mouseExited events consistent and makes hiding the hitWindow more reliable.
			// A nice side-effect is that it keeps the SceneKit animation view below the fake notch or the
			// ActivationView with the NCP.
			debugLog("reordering hitWindow")
			perform(#selector(reorderWindow), with: nil, afterDelay: 0.0)
		}
#endif
		
		if let sceneAnimationView = window?.childWindows?.last?.contentView as? SceneAnimationView {
			let point = self.convert(event.locationInWindow, from: nil)
			let hitResults = sceneAnimationView.hitTest(point, options: [:])
			if let hitResult = hitResults.first {
				let direction: CGFloat = Bool.random() ? -1 : 1
				let amount = CGFloat.random(in: 1...3) * direction * 10
				hitResult.node.physicsBody?.applyForce(SCNVector3(amount, 0, 0), at: SCNVector3(x: 0.5, y: 0.5, z: 0.5), asImpulse: true)
			}
		}
	}
	
	override var layerContentsRedrawPolicy: NSView.LayerContentsRedrawPolicy {
		get {
			return .onSetNeedsDisplay
		}
		set {
			// ignored
		}
	}
	
	override var wantsUpdateLayer: Bool {
		return true
	}
	
	override func updateLayer() {
		for (index, targetLayer) in self.targetLayers.enumerated() {
			let target = self.targets[index]
			CATransaction.withActionsDisabled {
				targetLayer.position = target.center
			}
		}
	}
	
	override var wantsLayer: Bool {
		get {
			return true
		}
		set {
			// ignored
		}
	}
	
#if false
	@objc
	private func reorderWindow() {
		if let parentWindow {
			window?.order(.below, relativeTo: parentWindow.windowNumber)
			debugLog("reordered hitWindow")
		}
	}
#endif
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		let result = super.hitTest(point)
		debugLog("point = \(point), result = \(String(describing: result))")
		return result
	}
	
}

extension CGPoint {

	public func moved(from: CGPoint, delta: CGFloat = 1.0) -> Bool {
		let deltaX = abs(x - from.x)
		let deltaY = abs(y - from.y)

		return (deltaX > delta) || (deltaY > delta)
	}

}

extension SceneHitView: SCNSceneRendererDelegate {
	
	func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		if time - lastTime > 0.25 {
			lastTime = time

			DispatchQueue.main.async { [self] in
				let rootNode = scene.rootNode
				
				let dieScene1 = rootNode.childNode(withName: "die1", recursively: true)!
				let node1 = dieScene1.childNode(withName: "D6", recursively: true)!
				
				let dieScene2 = rootNode.childNode(withName: "die2", recursively: true)!
				let node2 = dieScene2.childNode(withName: "D6", recursively: true)!
				
				let destination: SCNNode? = rootNode
				
				let target1 = targetForNode(node1, with: destination, in: renderer)
				let target2 = targetForNode(node2, with: destination, in: renderer)
				
				if target1.center.moved(from: lastTargetCenter1) || target2.center.moved(from: lastTargetCenter2) {
					self.targets = [target1, target2]
					lastTargetCenter1 = target1.center
					lastTargetCenter2 = target2.center
				}
				else {
					//debugLog("no change")
				}
			}
		}
	}

	func targetForNode(_ node: SCNNode, with destination: SCNNode?, in renderer: SCNSceneRenderer) -> SceneHitTarget {
		node.transform = node.presentation.transform

		let world = node.convertPosition(SCNVector3Zero, to: destination)
		let projectedWorldPoint = renderer.projectPoint(world)
		let worldPoint = CGPoint(x: projectedWorldPoint.x, y: projectedWorldPoint.y)
		//debugLog("worldPoint = \(worldPoint)")

		let (min, max) = node.boundingBox
		let projectedMinPoint = renderer.projectPoint(min)
		let minPoint = CGPoint(x: projectedMinPoint.x, y: projectedMinPoint.y)
		let projectedMaxPoint = renderer.projectPoint(max)
		let maxPoint = CGPoint(x: projectedMaxPoint.x, y: projectedMaxPoint.y)
		
		return SceneHitTarget(center: worldPoint, radius: (maxPoint.x - minPoint.x) * 0.9)
	}

}
