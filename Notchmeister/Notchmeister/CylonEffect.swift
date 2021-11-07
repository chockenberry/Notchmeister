//
//  CylonEffect.swift
//  Notchmeister
//
//  Created by Chris Parrish on 11/5/21.
//

import AppKit

class CylonEffect: NotchEffect {
        
    let redEyeLayer: CAGradientLayer
    let radius = 30.0
    let offset = 0
    
    required init (with parentLayer: CALayer) {
		self.redEyeLayer = CAGradientLayer()
        
		super.init(with: parentLayer)

		configureSublayers()
    }
    
    private func configureSublayers() {
        guard let parentLayer = parentLayer else { return }

        //center on the parent frame origin
        let origin = CGPoint(x: -(radius/2), y:-(radius/2))
        let size = CGSize(width: radius, height: radius)
        let frame = CGRect(origin: origin, size: size)
        redEyeLayer.frame = frame
        
        parentLayer.addSublayer(redEyeLayer)
        
        redEyeLayer.type = .radial
		redEyeLayer.colors = [NSColor.red.cgColor, NSColor.red.withAlphaComponent(0).cgColor]
        redEyeLayer.locations = [0,1]
        redEyeLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
        redEyeLayer.endPoint = CGPoint(x: 1,y: 1)
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
        animation.calculationMode = .paced
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.duration = 2.0
        
        redEyeLayer.add(animation, forKey: "Red Eye Animation")
    }
    
}
