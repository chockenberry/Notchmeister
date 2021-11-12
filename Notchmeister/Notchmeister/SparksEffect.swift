//
//  SparksEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/11/21.
//

import AppKit

class SparksEffect: NotchEffect {
	
	var sparksLayer: CAEmitterLayer

	required init(with parentLayer: CALayer) {
		self.sparksLayer = CAEmitterLayer()

		super.init(with: parentLayer)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		sparksLayer.emitterPosition = .zero
		sparksLayer.emitterSize = CGSize(width: 17, height: 23)
		sparksLayer.emitterShape = .rectangle
		sparksLayer.renderMode = .additive
		sparksLayer.contentsScale = parentLayer.contentsScale

		let sparkDimension = 10

		let cell = CAEmitterCell()
		cell.birthRate = 0
		// velocity * lifetime = distance travelled, which should be close to the padding (50 pts)
		cell.lifetime = 0.39
		cell.velocity = 200
		cell.scale = 0.1
		cell.scaleRange = 0.3
		cell.scaleSpeed = 0.5
		cell.contentsScale = parentLayer.contentsScale
		cell.yAcceleration = 0.5
		cell.emissionLongitude = .pi / 2
		cell.emissionRange = .pi / 4
		cell.spin = .pi * 2
		
		//cell.emissionRange = .pi * 2
		
		let image = NSImage(named: "sparksEffect-spark")!
		var proposedRect = CGRect(origin: .zero, size: CGSize(width: 10, height: 40))
		let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)

		cell.contents = cgImage
		
		cell.color = NSColor.orange.cgColor
		cell.redRange = 0.5
		cell.greenRange = 0.5
		cell.blueRange = 0
		
		/*
		 Animate color:
		 
		 newEmitter.name = @"fire";


		 //Set first before doing CABasicAnimation so it sticks
		 newEmitter.redSpeed = 1.0;

		 //Access the property with this key path format: @"emitterCells.<name>.<property>"
		 CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"emitterCells.fire.redSpeed"];
		 anim.fromValue = @(0.0);
		 anim.toValue = @(1.0);
		 anim.duration = 1.5;
		 anim.fillMode = kCAFillModeForwards;
		 [emitter addAnimation:anim forKey:@"emitterAnim"];
		 */
		
		sparksLayer.emitterCells = [cell]
		sparksLayer.opacity = 1

		parentLayer.addSublayer(sparksLayer)
	}

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		sparksLayer.emitterCells?.first?.birthRate = 0
	}
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		CATransaction.withActionsDisabled {
			if underNotch {
				let edgeDistance = edgeDistance(at: point)
				if edgeDistance > 0 {
					sparksLayer.emitterCells?.first?.birthRate = Float(edgeDistance / maxEdgeDistance()) * 1000
				}
				else {
					sparksLayer.emitterCells?.first?.birthRate = 0
				}
			}
			else {
				sparksLayer.emitterCells?.first?.birthRate = 0
			}

			debugLog("edgeDistance = \(edgeDistance(at: point))")
		
			sparksLayer.emitterPosition = point
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
	}

}
