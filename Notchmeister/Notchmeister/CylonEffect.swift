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
    
    required init (with parentLayer: CALayer) {
		super.init(with: parentLayer)

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
    }
    
	override func start() {
        guard let parentLayer = parentLayer else { return }
                
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
        animation.duration = 1.0
        animation.calculationMode = .paced
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.rotationMode = .rotateAuto
        
        redEyeLayer.add(animation, forKey: "Red Eye Animation")
    }

}
