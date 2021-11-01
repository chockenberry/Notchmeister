//
//  CoreAnimation.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import QuartzCore
import AppKit

extension CATransaction {
	
	class func withActionsDisabled(_ change: () -> Void) {
		begin()
		setDisableActions(true)
		change()
		commit()
	}
	
}

extension CAShapeLayer {
    
    class func notchOutlineLayer(for size: NSSize) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = NSBezierPath.notchPath(rect: NSRect(origin: .zero, size: size))
        layer.path = path.cgPath
        layer.bounds.size = size
        
        return layer
    }
    
}
