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
		//sparksLayer.emitterSize = CGSize(width: 17, height: 23)
		//sparksLayer.emitterShape = .rectangle
		sparksLayer.renderMode = .additive
		sparksLayer.contentsScale = parentLayer.contentsScale

		let sparkDimension = 10

		let cell = CAEmitterCell()
		cell.birthRate = 0
		// velocity * lifetime = distance travelled, which should be close to the padding (50 pts)
		cell.lifetime = 0.25
		cell.velocity = 195
		cell.scale = 0.25
		cell.scaleRange = 1
		cell.scaleSpeed = -0.55
		cell.contentsScale = parentLayer.contentsScale
		//cell.yAcceleration = 0.5
		cell.emissionLongitude = CGFloat.pi / 2
		cell.emissionRange = CGFloat.pi
		cell.spin = 0
		//cell.spin = .pi * 2
		
		//cell.emissionRange = .pi * 2
		
		//let image = NSImage(named: "sparksEffect-spark")!
		let image = NSImage(named: "spark")!
		var proposedRect = CGRect(origin: .zero, size: CGSize(width: 10, height: 40))
		let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)

		cell.contents = cgImage
		
		cell.color = NSColor.orange.cgColor
		cell.alphaSpeed = -0.5
		cell.alphaRange = 1
//		cell.redRange = 0.5
//		cell.greenRange = 0.5
//		cell.blueRange = 0
		
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
				sparksLayer.emitterCells?.first?.birthRate = 300
				/*
				let edgeDistance = edgeDistance(at: point)
				if edgeDistance > 0 {
					sparksLayer.emitterCells?.first?.birthRate = Float(edgeDistance / maxEdgeDistance()) * 300
				}
				else {
					sparksLayer.emitterCells?.first?.birthRate = 0
				}
				 */
			}
			else {
				sparksLayer.emitterCells?.first?.birthRate = 0
			}

			//debugLog("edgeDistance = \(edgeDistance(at: point))")
		
			sparksLayer.emitterPosition = point
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		sparksLayer.emitterCells?.first?.birthRate = 0
	}

}
