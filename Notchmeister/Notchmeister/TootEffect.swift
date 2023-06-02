//
//  TootEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 5/27/23.
//

import AppKit

class TootEffect: NotchEffect {
	
	var hasTooted = false
	var tootLayer: CAEmitterLayer // appropriate layer class

	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		self.tootLayer = CAEmitterLayer()

		super.init(with: parentLayer, in: parentView, of: parentWindow)


		configureSublayers()
	}
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }
		
		tootLayer.emitterPosition = CGPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.midY)
		tootLayer.renderMode = .oldestFirst
		tootLayer.emitterShape = .line
		tootLayer.emitterSize = CGSize(width: parentLayer.bounds.width - 40, height: 1)
		tootLayer.contentsScale = parentLayer.contentsScale
		tootLayer.zPosition = 0
		
		let cell = CAEmitterCell()
		cell.birthRate = 0
		// velocity * lifetime = distance travelled, which should be close to the padding (50 pts)
		cell.lifetime = 5
		cell.velocity = 1
		cell.velocityRange = 0
		
		cell.scale = 2
		cell.scaleRange = 1
		cell.scaleSpeed = 0
		cell.contentsScale = parentLayer.contentsScale
		cell.yAcceleration = 20
//		cell.emissionLongitude = -.pi/2
//		//cell.emissionRange = .pi
		cell.spin = 0
		
		let image = NSImage(named: "spark")!
		var proposedRect = CGRect(origin: .zero, size: CGSize(width: 10, height: 40))
		let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
		cell.contents = cgImage
		
		cell.name = "tootEmitter"
		
		cell.color = NSColor(named: "tootEffect")!.withAlphaComponent(0.5).cgColor
		//cell.color = NSColor.cyan.withAlphaComponent(0.5).cgColor
		cell.alphaSpeed = -1.0 / cell.lifetime // thank you Andrei Ardelean https://stackoverflow.com/a/25461549

		tootLayer.emitterCells = [cell]
		tootLayer.opacity = 1
		tootLayer.birthRate = 1
		
		parentLayer.addSublayer(tootLayer)
	}

#if DEBUG
	var lastToot: Date = Date.distantPast
#endif
	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		let tootDuration: TimeInterval = 10
		
		if underNotch {
			if !hasTooted {
				debugLog("not hasTooted...")
#if DEBUG

				if lastToot.timeIntervalSinceNow > -60 {
					debugLog("hasTooted updated recently - repeat?")
				}
				lastToot = Date()
#endif

				if let sound = NSSound(named: "autotoot") {
					if !sound.isPlaying {
						sound.play()
					}
					
					do {
						tootLayer.beginTime = CACurrentMediaTime()
						CATransaction.begin()
						
						let animation = CAKeyframeAnimation(keyPath: "emitterCells.tootEmitter.birthRate")
						animation.duration = tootDuration
						animation.keyTimes = 	[0.15,	0.25,	0.50,	0.75,	0.76,	1]
						animation.values =   	[20,	40,		60,		20,		0,		0]
						animation.beginTime = tootLayer.convertTime(CACurrentMediaTime(), from: nil) + 0.5
						
						animation.repeatCount = 0
						animation.autoreverses = false
						animation.fillMode = .forwards
						animation.isRemovedOnCompletion = true

						CATransaction.setCompletionBlock{ [weak self] in
							debugLog("resetting hasTooted...")
							self?.hasTooted = false
						}

						tootLayer.add(animation, forKey: "tootRate")

						CATransaction.commit()
					}
					
					debugLog("setting hasTooted...")
					hasTooted = true
				}
			}
		}
	}

}

