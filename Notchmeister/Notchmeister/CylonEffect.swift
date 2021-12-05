//
//  CylonEffect.swift
//  Notchmeister
//
//  Created by Chris Parrish on 11/5/21.
//

import AppKit

class CylonEffect: NotchEffect {
        
    let redEyeLayer = CALayer()
    let irisLayer = CALayer()
    let glowLayer = CAGradientLayer()
    
    let eyeWidth = 10.0
    let eyeHeight = 4.0
    let glowHorizontalInset = -16.0
    let glowVerticalInset = -20.0
    
    let irisColor = NSColor(srgbRed: 0.9979979396, green: 0.4895141721, blue: 0.491407156, alpha: 1.0)
    let glowStartColor = NSColor(srgbRed: 0.82, green: 0.22, blue: 0.19, alpha: 1.0)
    
	var redEyeAnimation: CAKeyframeAnimation?
	
	required init (with parentLayer: CALayer, in parentView: NSView) {
		super.init(with: parentLayer, in: parentView)

		configureSublayers()
    }
    
    private func configureSublayers() {
        guard let parentLayer = parentLayer else { return }

        let irisBounds = CGRect(origin: .zero, size: CGSize(width: eyeWidth, height: eyeHeight))
        var glowBounds = irisBounds.insetBy(dx: glowHorizontalInset, dy: glowVerticalInset)
        glowBounds.origin = .zero
                
        redEyeLayer.frame = glowBounds
        parentLayer.addSublayer(redEyeLayer)
                        
        // iris
        
        irisLayer.backgroundColor = irisColor.cgColor

        irisLayer.bounds = irisBounds
        irisLayer.position = CGPoint(x: redEyeLayer.bounds.midX, y: redEyeLayer.bounds.midY)

        irisLayer.cornerRadius = eyeHeight / 2.0
        redEyeLayer.addSublayer(irisLayer)

        // glow
        
        let glowEndColor = glowStartColor.withAlphaComponent(0.0)

        glowLayer.type = .radial
        glowLayer.colors = [glowStartColor.cgColor, glowEndColor.cgColor]
        glowLayer.locations = [0,1]
        glowLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
        glowLayer.endPoint = CGPoint(x: 1,y: 1)
        
        glowLayer.bounds = glowBounds
        glowLayer.position = NSPoint(x: redEyeLayer.bounds.midX, y: redEyeLayer.bounds.midY )
        
        redEyeLayer.insertSublayer(glowLayer, below: irisLayer)
		
		redEyeLayer.opacity = 0
    }
   
	var cylonAlert = false
	
	let redEyeScanningDuration: CFTimeInterval = 1
	
	private func startScanning() {
		guard let parentLayer = parentLayer else { return }

		if redEyeLayer.animation(forKey: "Red Eye Animation") == nil {
			if redEyeAnimation == nil {
				debugLog("creating scanning animation")
				let path = NSBezierPath.notchPath(size: parentLayer.bounds.size)
				
				// becasue our parent layer is in a flipped coordinate space
				// we have to flip the path to match if we want to animate
				// along the outline of the notch view
				
				if (parentLayer.isGeometryFlipped) {
					var flipTransform = AffineTransform(scaleByX: 1, byY: -1)
					flipTransform.translate(x: 0, y: -parentLayer.bounds.height)
					path.transform(using: flipTransform)
				}
				
				let animation = CAKeyframeAnimation(keyPath: "position")
				
				animation.path = path.cgPath
				animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
				animation.duration = redEyeScanningDuration
				animation.calculationMode = .paced
				animation.repeatCount = .infinity
				animation.autoreverses = true
				animation.rotationMode = .rotateAuto
				
				redEyeAnimation = animation
			}
			
			redEyeLayer.add(redEyeAnimation!, forKey: "Red Eye Animation")
		}
	}
	
	var scanningTimer: Timer?

	var isScanning = false

	var pausedTime: CFTimeInterval = 0
	
	private func pauseScanning() {
		pausedTime = redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
		//let pausedTime = redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
		redEyeLayer.speed = 0
		redEyeLayer.timeOffset = pausedTime
	}
	
	private func resumeScanning() {
		//let pausedTime = redEyeLayer.timeOffset
		redEyeLayer.speed = 1
		redEyeLayer.timeOffset = 0
		redEyeLayer.beginTime = 0
		let timeSincePause = redEyeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
		redEyeLayer.beginTime = timeSincePause
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
		
		debugLog()
		
		cylonAlert = false
		
		startScanning()
		
		redEyeLayer.removeAnimation(forKey: "opacity")
		if scanningTimer == nil {
			resumeScanning()
		}
		else {
			scanningTimer?.invalidate()
			scanningTimer = nil
		}
		redEyeLayer.opacity = 1

	}
	
	let cylonProtectionDistance: Int = 6 // pointer hotspot offset is 4
	let cylonProtectionThreshold: Int = 2

	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		redEyeLayer.opacity = 1

		let edgeDistance = edgeDistance(at: point)
		//debugLog("edgeDistance = \(edgeDistance), cylonAlert = \(cylonAlert)")

		var blockMouse = false
		if edgeDistance < 0 {
			// outside of notch
			//debugLog("outside of notch")
			if !cylonAlert && abs(edgeDistance) < 5 {
				//debugLog("blocking mouse")
				blockMouse = true
			}
		}
		else {
			// under notch
			//debugLog("under notch, blocking mouse")
			blockMouse = true
		}
		
		if blockMouse {
			guard let parentView = parentView else { return }
			guard let screen = parentView.window?.screen else { return }
			let screenFrame = screen.frame
			let randomOffset = CGPoint(x: Int.random(in: -cylonProtectionDistance...cylonProtectionDistance), y: Int.random(in: 0...cylonProtectionDistance))
			let viewPoint = CGPoint(x: point.x + randomOffset.x, y: parentView.bounds.maxY + randomOffset.y)
			let windowPoint = parentView.convert(viewPoint, to: nil)
			guard let screenPoint = parentView.window?.convertPoint(toScreen: windowPoint) else { return } // origin in lower-left corner
			let globalPoint = CGPoint(x: screenPoint.x, y: screenFrame.size.height - screenPoint.y) // origin in upper-left corner

			CGWarpMouseCursorPosition(globalPoint)
			
			cylonAlert = true
		}
		else {
			if cylonAlert {
				if edgeDistance < -CGFloat(cylonProtectionDistance + cylonProtectionThreshold) {
					cylonAlert = false
					//startScanning()
					resumeScanning()
				}
			}
		}
		
		if (cylonAlert) {
			//guard let animation = redEyeLayer.animation(forKey: "Red Eye Animation") else { return }
			//guard let position = redEyeLayer.presentation()?.position else { return }
			//redEyeLayer.removeAnimation(forKey: "Red Eye Animation")

			pauseScanning()
//			pausedTime = redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
//
//			redEyeLayer.speed = 0
			redEyeLayer.timeOffset = point.x / parentLayer.bounds.width
//			redEyeLayer.timeOffset = pausedTime

//			redEyeAnimation?.beginTime = 0.5

			//redEyeLayer.position = CGPoint(x: point.x, y: parentLayer.bounds.maxY)
		}
	}
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		debugLog()

//		pausedTime = redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
//		let pausedTime = redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
//		redEyeLayer.speed = 0
//		redEyeLayer.timeOffset = pausedTime
		
		//redEyeLayer.opacity = 0
		//redEyeLayer.speed = 0
		
		if scanningTimer != nil {
			debugLog("cancelling timer")
			scanningTimer?.invalidate()
			scanningTimer = nil

			redEyeLayer.removeAnimation(forKey: "opacity")
		}
		
		scanningTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { timer in
			debugLog("scanning spindown")
			self.redEyeLayer.opacity = 0

			CATransaction.begin()
			CATransaction.setCompletionBlock { [weak self] in
				if self?.redEyeLayer.presentation()?.opacity == 0 {
					debugLog("scanning paused")
					self?.pauseScanning()
				}
			}
			
			let animation = CABasicAnimation(keyPath: "opacity")
			animation.duration = 1
			animation.fromValue = 1
			animation.toValue = 0
			animation.isRemovedOnCompletion = true
			self.redEyeLayer.add(animation, forKey: "opacity")

//			self.pausedTime = self.redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
			
//			let pausedTime = self.redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
//			self.redEyeLayer.speed = 0
//			self.redEyeLayer.timeOffset = pausedTime
			
			//redEyeLayer.speed = 0
			
			CATransaction.commit()
			
			self.scanningTimer = nil
		})
	}
}
