//
//  NotchView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import AppKit

class NotchView: NSView {

//	var trackingArea: NSTrackingArea?
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
			// create a tracking area for mouse movements
			let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .mouseMoved]
			
			// TODO: Adding padding to track the mouse outside the view sometimes loses events.
			// It's probably safer to add the trackingRect to the content view and pass the mouse
			// events down to this view.
			
			// NOTE: The negative inset on the top of the view might be causing a problem here:
			//let trackingRect = bounds.insetBy(dx: -notchPadding, dy: -notchPadding)
//			let origin = CGPoint(x: bounds.origin.x - notchPadding, y: 0)
//			let size = CGSize(width: bounds.width + notchPadding * 2, height: bounds.height + notchPadding)
//			let trackingRect = CGRect(origin: origin, size: size)
//			let trackingArea = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
//			self.trackingArea = trackingArea
//			addTrackingArea(trackingArea)
			
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
			
//			if let trackingArea = trackingArea {
//				removeTrackingArea(trackingArea)
//				self.trackingArea = nil
//			}
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
		if trackingMouse {
			let point = notchLocation(with: windowPoint)
			let underNotch = bounds.contains(point)
			debugLog("point = \(point), underNotch = \(underNotch)")
			notchEffect?.mouseMoved(at: point, underNotch: underNotch)
		}
		else {
			debugLog("not tracking mouse")
		}
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



