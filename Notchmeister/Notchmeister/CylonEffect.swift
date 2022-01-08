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
	
	private func createScanner() {
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
	
	// this is a helluva state machine - seems appropriate for a Cylon
	var scanningTimer: Timer? // a timer that lets the scanner run for awhile after the mouse leaves the tracking area
	var isScanning = false // a flag that indicates if the redEyeAnimation is running with a speed of 1, or stopped at 0
	var pausedTime: CFTimeInterval = 0 // the time of the current paused animation - adjusted to stay near mouse
	
	private func pauseScanning() {
		if isScanning {
			pausedTime = redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
			debugLog("pausing scan at \(pausedTime)")
			redEyeLayer.speed = 0
			redEyeLayer.timeOffset = pausedTime
		}
		isScanning = false
	}
	
	private func resumeScanning() {
		if !isScanning {
			debugLog("resuming scan at \(pausedTime)")
			redEyeLayer.speed = 1
			redEyeLayer.timeOffset = 0
			redEyeLayer.beginTime = 0
			let timeSincePause = redEyeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
			redEyeLayer.beginTime = timeSincePause
		}
		isScanning = true
	}
	
	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		debugLog()
		
		cylonAlert = false
		
		createScanner()
		
		redEyeLayer.removeAnimation(forKey: "opacity")
		if scanningTimer != nil {
			scanningTimer?.invalidate()
			scanningTimer = nil
		}
		
		resumeScanning()
		CATransaction.withActionsDisabled {
			redEyeLayer.opacity = 1
		}
	}
	
	let cylonProtectionDistance: Int = 6 // pointer hotspot offset is 4
	let cylonProtectionThreshold: Int = 2

	
	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let edgeDistance = edgeDistance(at: point)
		//debugLog("edgeDistance = \(edgeDistance), cylonAlert = \(cylonAlert)")

		var blockMouse = false
		if edgeDistance < 0 {
			// outside of notch
			if !cylonAlert && abs(edgeDistance) < 5 {
				//debugLog("blocking mouse")
				blockMouse = true
			}
		}
		else {
			// under notch
			blockMouse = true
		}

		guard let parentView = parentView else { return }

		let bounds = parentView.bounds
		let leftDistance = abs(point.x - bounds.minX)
		let rightDistance = abs(point.x - bounds.maxX)
		let bottomDistance = abs(point.y - bounds.maxY)

		if blockMouse {
			guard let zeroScreen = NSScreen.screens.first else { return }
			let viewPoint: CGPoint
			// the randomOffsets make the mouse movement annoying - unless you back off
			if leftDistance < bottomDistance {
				let randomOffset = CGPoint(x: Int.random(in: -cylonProtectionDistance...0), y: Int.random(in: -cylonProtectionDistance...cylonProtectionDistance))
				viewPoint = CGPoint(x: bounds.minX + randomOffset.x, y: point.y + randomOffset.y)
			}
			else if rightDistance < bottomDistance {
				let randomOffset = CGPoint(x: Int.random(in: 0...cylonProtectionDistance), y: Int.random(in: -cylonProtectionDistance...cylonProtectionDistance))
				viewPoint = CGPoint(x: bounds.maxX + randomOffset.x, y: point.y + randomOffset.y)
			}
			else {
				let randomOffset = CGPoint(x: Int.random(in: -cylonProtectionDistance...cylonProtectionDistance), y: Int.random(in: 0...cylonProtectionDistance))
				viewPoint = CGPoint(x: point.x + randomOffset.x, y: parentView.bounds.maxY + randomOffset.y)
			}
			let windowPoint = parentView.convert(viewPoint, to: nil)
			guard let screenPoint = parentView.window?.convertPoint(toScreen: windowPoint) else { return } // origin in lower-left corner, of main screen
			let globalPoint = CGPoint(x: screenPoint.x, y: -screenPoint.y + zeroScreen.frame.size.height) // origin in upper-left corner of main screen
			// to transform the point to inverted global coordinates we:
			// scale by -1 (invert)
				// translate the scaled origin to top of main screen

			CGWarpMouseCursorPosition(globalPoint)
			
			cylonAlert = true
		}
		else {
			if cylonAlert {
				if edgeDistance < -CGFloat(cylonProtectionDistance + cylonProtectionThreshold) {
					cylonAlert = false
					resumeScanning()
				}
			}
		}
		
		if (cylonAlert) {
			if isScanning {
				pauseScanning()
			}
			
			let bounds = parentLayer.bounds
			let timeDistance = bounds.height + bounds.width + bounds.height // an approximation, doesn't take radii into account
			let pointDistance: CGFloat
			if leftDistance < bottomDistance {
				pointDistance = point.y
			}
			else if rightDistance < bottomDistance {
				pointDistance = bounds.height + bounds.width + (bounds.height - point.y)
			}
			else {
				pointDistance = bounds.height + point.x
			}
			var timeOffset = pointDistance / timeDistance
			// a timeOffset of 0, or close to it, causes the red eye to move unpredicably - even robots don't like floating point precision
			if timeOffset < 0.005 {
				timeOffset = 0.005
			}
			
			redEyeLayer.timeOffset = timeOffset
			pausedTime = redEyeLayer.convertTime(CACurrentMediaTime(), from:nil)
			debugLog("moved scan to \(redEyeLayer.timeOffset) from \(pausedTime)")
		}
	}
	
	let spindownTimeInterval: CFTimeInterval = 3.0
	let disappearTimeInterval: CFTimeInterval = 0.5
	
	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		debugLog()
		
		if scanningTimer != nil {
			debugLog("cancelling timer")
			scanningTimer?.invalidate()
			scanningTimer = nil
		}
		
		scanningTimer = Timer.scheduledTimer(withTimeInterval: spindownTimeInterval, repeats: false, block: { timer in
			debugLog("scanning spindown")
			self.redEyeLayer.opacity = 0

			CATransaction.begin()
			CATransaction.setCompletionBlock { [weak self] in
				// NOTE: This is a nasty way to check if the animation completed (instead of delegate to watch for it
				// being cancelled or removed. A "slight error in programming" never caused anything bad to happen, right?
				if self?.redEyeLayer.presentation()?.opacity == 0 {
					debugLog("scanning paused")
					self?.pauseScanning()
				}
			}
			
			let animation = CABasicAnimation(keyPath: "opacity")
			animation.duration = self.disappearTimeInterval
			animation.fromValue = 1
			animation.toValue = 0
			animation.isRemovedOnCompletion = true
			self.redEyeLayer.add(animation, forKey: "opacity")

			CATransaction.commit()
			
			self.scanningTimer = nil
		})
	}
}
