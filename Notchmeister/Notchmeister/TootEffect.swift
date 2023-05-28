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
		tootLayer.renderMode = .oldestLast
		tootLayer.emitterShape = .line
		tootLayer.emitterSize = CGSize(width: parentLayer.bounds.width - 20, height: 1.0)
		tootLayer.contentsScale = parentLayer.contentsScale
		
		let cell = CAEmitterCell()
		cell.birthRate = 10
		// velocity * lifetime = distance travelled, which should be close to the padding (50 pts)
		cell.lifetime = 5
		cell.velocity = 1
		
		cell.scale = 1.5
		cell.scaleRange = 1
		cell.scaleSpeed = 0.1
		cell.contentsScale = parentLayer.contentsScale
		cell.yAcceleration = 40
		cell.emissionLongitude = -.pi/2
		cell.emissionRange = .pi
		cell.spin = 0
		
		let image = NSImage(named: "spark")!
		var proposedRect = CGRect(origin: .zero, size: CGSize(width: 10, height: 40))
		let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
		
		cell.contents = cgImage
		
		cell.name = "tootEmitter"
		
		cell.color = NSColor(named: "tootEffect")!.cgColor
		cell.alphaSpeed = -1.0 / cell.lifetime // thank you Andrei Ardelean https://stackoverflow.com/a/25461549
		//cell.alphaSpeed = 2.0
		//cell.alphaRange = 1
		//cell.redRange = 0
		//cell.greenRange = 0
		//cell.blueRange = 0
		
		
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
		
//		if Defaults.shouldDebugDrawing {
//			tootLayer.backgroundColor = NSColor.systemRed.cgColor
//		}
//		else {
//			tootLayer.backgroundColor = NSColor.clear.cgColor
//		}

		tootLayer.emitterCells = [cell]
		tootLayer.opacity = 1
		tootLayer.birthRate = 0

		//tootLayer.emitterCells?.first?.isEnabled = false
		/*
		let keyPath = "emitterCells.tootEmitter.color"
		
		//tootLayer.setValue(NSColor(red: 0, green: 0, blue: 1, alpha: 0.5).cgColor, forKeyPath: keyPath)

#if false
		let colorAnimation = CABasicAnimation(keyPath: keyPath)
		colorAnimation.beginTime = CACurrentMediaTime()
		colorAnimation.fromValue = NSColor.black.cgColor
		colorAnimation.toValue = NSColor.clear.cgColor
		colorAnimation.duration = 2
		colorAnimation.fillMode = .forwards
		tootLayer.add(colorAnimation, forKey: "coloring")
#else
		let anim2 = CAKeyframeAnimation(keyPath: keyPath)
		anim2.beginTime = CACurrentMediaTime()
		anim2.duration = 5
		anim2.keyTimes = [0, 0.25, 0.5, 0.75, 1]
		anim2.repeatCount = 20
		anim2.values = [NSColor.red.cgColor, NSColor.blue.cgColor, NSColor.yellow.cgColor, NSColor.cyan.cgColor, NSColor.magenta.cgColor]
//		anim2.values = [NSColor.red, NSColor.blue, NSColor.yellow, NSColor.cyan, NSColor.magenta]

		tootLayer.add(anim2, forKey: "coloring")
#endif
		*/
		
		parentLayer.addSublayer(tootLayer)
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
//		edgeLayer.opacity = 1
		hasTooted = false
		debugLog("stopping emitter")
		//tootLayer.emitterCells?.first?.birthRate = 0
		tootLayer.birthRate = 0
		tootLayer.removeAllAnimations()
		//tootLayer.emitterCells?.first?.isEnabled = true
	}

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		
		guard let parentLayer = parentLayer else { return }

//		tootLayer.emitterPosition = CGPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.midY)
		//tootLayer.emitterPosition = point //CGPoint(x: parentLayer.bounds.minX, y: parentLayer.bounds.minY)
//		tootLayer.emitterPosition = CGPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.midY)
		//tootLayer.emitterPosition = CGPoint(x: 84, y: 32)

		//tootLayer.birthRate = 10
		//tootLayer.emitterCells?.first?.birthRate = 10

		if underNotch {
			//if tootLayer.emitterCells?.first?.birthRate == 0 {
			//if tootLayer.presentation()?.birthRate == 0 {
			if !hasTooted {
				debugLog("starting emitter")
				//tootLayer.emitterCells?.first?.birthRate = 10
				
				//let animation = CABasicAnimation()
				let animation = CAKeyframeAnimation(keyPath: "birthRate")
				animation.duration = 10
				//animation.fromValue = 0
				//animation.toValue = 20
				animation.keyTimes = [0, 0.1, 0.15, 0.25, 1]
				animation.values = [0, 0, 20, 30, 0]
				
				animation.repeatCount = 0
				animation.autoreverses = false
				animation.fillMode = .forwards
				tootLayer.add(animation, forKey: "toot")
//				CABasicAnimation *birthRateAnim = [CABasicAnimation animationWithKeyPath:@"birthRate"];
//				birthRateAnim.duration = 5.0f;
//				birthRateAnim.fromValue = [NSNumber numberWithFloat:((CAEmitterLayer *)emitterLayer).birthRate];
//				birthRateAnim.toValue = [NSNumber numberWithFloat:0.0f];
//				birthRateAnim.repeatCount = 0;
//				birthRateAnim.autoreverses = NO;
//				birthRateAnim.fillMode = kCAFillModeForwards;
//				[((CAEmitterLayer *)emitterLayer) addAnimation:birthRateAnim forKey:@"finishOff"];

//				CATransaction.withActionsDisabled {
//					tootLayer.birthRate = 10
//				}
				
//				let keyPath = "emitterCells.tootEmitter.color"
//				let colorAnimation = CABasicAnimation(keyPath: keyPath)
//				colorAnimation.beginTime = CACurrentMediaTime()
//				colorAnimation.fromValue = NSColor.white.cgColor
//				colorAnimation.toValue = NSColor.clear.cgColor
//				colorAnimation.duration = 5
//				colorAnimation.fillMode = .forwards
//				tootLayer.add(colorAnimation, forKey: "coloring")

			}
		}
		
		if underNotch {
			if !hasTooted {
				if let sound = NSSound(named: "autotoot") {
					if !sound.isPlaying {
						sound.play()
						hasTooted = true
						
					}
				}
			}
		}
		else {
//			tootLayer.emitterCells?.first?.birthRate = 0
		}
		
	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
//		edgeLayer.opacity = 0
		debugLog("stopping emitter")
		//tootLayer.emitterCells?.first?.birthRate = 0
		//tootLayer.birthRate = 0
		//tootLayer.removeAllAnimations()
	}

}

