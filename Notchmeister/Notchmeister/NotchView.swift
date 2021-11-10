//
//  NotchView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import AppKit

class NotchView: NSView {

	var trackingMouse: Bool = false
	
    var notchOutlineLayer: CAShapeLayer?
	var notchEffect: NotchEffect?
	
    // MARK: - NSView
    
	override var isFlipped: Bool {
		get {
			// things are easier if the view and layer origins are in the upper left corner
			return true
		}
	}

    override func updateLayer() {
        guard let notchOutlineLayer = notchOutlineLayer else { return }

        notchOutlineLayer.fillColor = Defaults.shouldDrawNotchFill ? NSColor.black.cgColor : NSColor.clear.cgColor
        notchOutlineLayer.strokeColor = Defaults.shouldDrawNotchOutline ? NSColor.white.cgColor : NSColor.clear.cgColor
        notchOutlineLayer.lineWidth = 2.0
    }
    
	private let notchPadding: CGFloat = 50
	
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

                // effect under the outline so we can use the outline layer
                // to cover the effect in screen captures
                // or on notchless displays
				switch (Defaults.selectedEffect) {
				case 0:
					notchEffect = createGlowEffect()
				case 1:
					notchEffect = createCylonEffect()
				default:
					notchEffect = nil
				}
                notchEffect?.start()
                
                createOutlineLayer()
			}
		}
		else {
			notchEffect?.end()
			notchEffect = nil
		}
	}
	
    private func createOutlineLayer() {
        guard let layer = layer else { return }
        
        let outlineLayer = CAShapeLayer.notchOutlineLayer(for: bounds.size)
                
        outlineLayer.masksToBounds = false
        
        outlineLayer.anchorPoint = .zero
        outlineLayer.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
        layer.addSublayer(outlineLayer)
        
        outlineLayer.isGeometryFlipped = isFlipped

        notchOutlineLayer = outlineLayer
    }
    
    private func createCylonEffect() -> CylonEffect? {
        guard let parentLayer = self.layer else { return nil }
        return CylonEffect(with: parentLayer)
    }

	private func createGlowEffect() -> GlowEffect? {
		guard let parentLayer = self.layer else { return nil }
		return GlowEffect(with: parentLayer)
	}

	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return true
	}

	override func hitTest(_ point: NSPoint) -> NSView? {
		//return debugResult(self.layer?.hitTest(point) == nil ? nil : super.hitTest(point))
		return debugResult(super.hitTest(point))
	}

    //MARK: - NSResponder

	func notchLocation(with windowPoint: CGPoint) -> NSPoint {
		return self.convert(windowPoint, from: nil)
	}
	
	func mouseEntered(windowPoint: CGPoint) {
		debugLog()
		trackingMouse = true
		
		//NSCursor.hide() // NOTE: This only works when the app is frontmost, which in this case is unlikely.

		let point = notchLocation(with: windowPoint)
		let underNotch = bounds.contains(point)
		notchEffect?.mouseEntered(at: point, underNotch: underNotch)
	}
	
	func mouseMoved(windowPoint: CGPoint) {
		//if trackingMouse {
			let point = notchLocation(with: windowPoint)
			let underNotch = bounds.contains(point)
			debugLog("point = \(point), underNotch = \(underNotch)")
			notchEffect?.mouseMoved(at: point, underNotch: underNotch)
		//}
		//else {
		//	debugLog("not tracking mouse")
		//}
	}
	
	func mouseExited(windowPoint: CGPoint) {
		debugLog()
		trackingMouse = false

		//NSCursor.unhide() // NOTE: This only works when the app is frontmost, which in this case is unlikely.

		let point = notchLocation(with: windowPoint)
		let underNotch = bounds.contains(point)
		notchEffect?.mouseExited(at: point, underNotch: underNotch)
	}
}



