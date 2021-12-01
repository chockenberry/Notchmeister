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

//    override func updateLayer() {
//        guard let notchOutlineLayer = notchOutlineLayer else { return }
//
//        notchOutlineLayer.fillColor = Defaults.shouldDrawNotchFill ? NSColor.black.cgColor : NSColor.clear.cgColor
//        notchOutlineLayer.strokeColor = Defaults.shouldDrawNotchOutline ? NSColor.white.cgColor : NSColor.clear.cgColor
//        notchOutlineLayer.lineWidth = 2.0
//    }
    
	//private let notchPadding: CGFloat = 50
	
	override func viewDidMoveToSuperview() {
		if self.superview != nil {
			// create a layer hosting view
			wantsLayer = true
			if let layer = layer {
				layer.masksToBounds = false
				if Defaults.shouldDebugDrawing {
					layer.backgroundColor = NSColor.systemRed.cgColor
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
		//debugLog("point = \(point), underNotch = \(underNotch)")
		notchEffect?.mouseMoved(at: point, underNotch: underNotch)
	}
	
	func mouseExited(windowPoint: CGPoint) {
		//debugLog()
		let point = notchLocation(with: windowPoint)
		let underNotch = bounds.contains(point)
		notchEffect?.mouseExited(at: point, underNotch: underNotch)
	}
}



