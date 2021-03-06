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

