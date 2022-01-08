//
//  NotchView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import AppKit

class NotchView: NSView {
	
	var notchEffect: NotchEffect?
	
    // MARK: - NSView
    
	override var isFlipped: Bool {
		get {
			// things are easier if the view and layer origins are in the upper left corner
			return true
		}
	}
	
	override func viewDidMoveToSuperview() {
		if self.superview != nil {
			// create a layer hosting view
			wantsLayer = true
			if let layer = layer {
				layer.masksToBounds = false
				if Defaults.shouldDebugDrawing {
					layer.backgroundColor = NSColor.systemRed.withAlphaComponent(0.25).cgColor
				}
				else {
					layer.backgroundColor = NSColor.clear.cgColor
				}

				guard let parentLayer = self.layer else { return }

				let effect = Effects(rawValue: Defaults.selectedEffect)
				notchEffect = effect?.notchEffect(with: parentLayer, in: self)
 
				notchEffect?.start()
			}
		}
		else {
			notchEffect?.end()
			notchEffect = nil
		}
	}
    
    //MARK: - NSResponder

	func notchLocation(with windowPoint: CGPoint) -> NSPoint {
		return self.convert(windowPoint, from: nil)
	}
	
	func mouseEntered(windowPoint: CGPoint) {
		//debugLog()
		let point = notchLocation(with: windowPoint)
		let underNotch = bounds.contains(point)
		notchEffect?.mouseEntered(at: point, underNotch: underNotch)
	}
	
	func mouseMoved(windowPoint: CGPoint) {
		let point = notchLocation(with: windowPoint)
		let underNotch = bounds.contains(point)
		notchEffect?.mouseMoved(at: point, underNotch: underNotch)
	}
	
	func mouseExited(windowPoint: CGPoint) {
		//debugLog()
		let point = notchLocation(with: windowPoint)
		let underNotch = bounds.contains(point)
		notchEffect?.mouseMoved(at: point, underNotch: underNotch)
		notchEffect?.mouseExited(at: point, underNotch: underNotch)
	}
}



