//
//  PlasmaEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/11/21.
//

import AppKit

class PlasmaEffect: NotchEffect {
	
	var plasmaLayer: CAEmitterLayer
	var lifetimeScale: Float
	
	required init (with parentLayer: CALayer, in parentView: NSView) {
		self.plasmaLayer = CAEmitterLayer()

		self.lifetimeScale = (NSScreen.hasNotchedScreen || Defaults.shouldLargeFakeNotch) ? 0.1 : 0.075
		
		super.init(with: parentLayer, in: parentView)

		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		plasmaLayer.emitterPosition = .zero
		plasmaLayer.renderMode = .additive
		plasmaLayer.contentsScale = parentLayer.contentsScale

		let cell = CAEmitterCell()
		cell.birthRate = 0
		// velocity * lifetime = distance travelled, which should be close to the padding (50 pts)
		cell.lifetime = 0.2
		cell.velocity = 150
		cell.scale = 0.25
		cell.scaleRange = 1
		cell.scaleSpeed = -0.55
		cell.contentsScale = parentLayer.contentsScale
		cell.yAcceleration = 800
		cell.emissionLongitude = CGFloat.pi / 2
		cell.emissionRange = CGFloat.pi
		cell.spin = 0

		let image = NSImage(named: "spark")!
		var proposedRect = CGRect(origin: .zero, size: CGSize(width: 10, height: 40))
		let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)

		cell.contents = cgImage
		
		cell.color = NSColor(named: "plasmaEffect-base")?.cgColor
		cell.alphaSpeed = -0.5
		cell.alphaRange = 1
		cell.redRange = 0.2
		cell.blueRange = 0.1
		
		/*
		 To animate color:
		 
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
		
		plasmaLayer.emitterCells = [cell]
		plasmaLayer.opacity = 1

		parentLayer.addSublayer(plasmaLayer)
	}

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		plasmaLayer.emitterCells?.first?.birthRate = 0
	}
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		CATransaction.withActionsDisabled {
			if let emitterCell = plasmaLayer.emitterCells?.first {
				if underNotch {
					let edgeDistance = edgeDistance(at: point)
					if edgeDistance > 0 {
						let normalizedEdgeDistance = Float(edgeDistance / maxEdgeDistance())
						emitterCell.lifetime = 0.2 + (lifetimeScale * normalizedEdgeDistance)
					}
					emitterCell.birthRate = 300
				}
				else {
					emitterCell.birthRate = 0
				}
			}
			
			plasmaLayer.emitterPosition = point
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		plasmaLayer.emitterCells?.first?.birthRate = 0
	}

}
