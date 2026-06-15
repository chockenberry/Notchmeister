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
	
	class func withChange(duration: CFTimeInterval, _ change: () -> Void, completion: (() -> Void)? = nil) {
		begin()
		setAnimationDuration(duration)
		if completion != nil {
			setCompletionBlock(completion)
		}
		change()
		commit()
	}
}

