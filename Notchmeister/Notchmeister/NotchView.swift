//
//  NotchView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 10/29/21.
//

import AppKit

class NotchView: NSView {

	var trackingArea: NSTrackingArea?
	var mouseInView: Bool = false
	
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
    
	override func viewDidMoveToSuperview() {
		if self.superview != nil {
			// create a tracking area for mouse movements
			let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .mouseMoved]
			let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
			self.trackingArea = trackingArea
			addTrackingArea(trackingArea)
			
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
			
			if let trackingArea = trackingArea {
				removeTrackingArea(trackingArea)
				self.trackingArea = nil
			}
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
    
	func notchLocation(with event: NSEvent) -> NSPoint {
		let locationInWindow = event.locationInWindow
		return self.convert(locationInWindow, from: nil)
	}
	
	override func mouseEntered(with event: NSEvent) {
		debugLog()
		mouseInView = true
		
		//NSCursor.hide() // NOTE: This only works when the app is frontmost, which in this case is unlikely.

		notchEffect?.mouseEntered(at: notchLocation(with: event))
	}
	
	override func mouseMoved(with event: NSEvent) {
		if mouseInView {
			//debugLog("point = \(notchLocation(with: event))")
			notchEffect?.mouseMoved(at: notchLocation(with: event))
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		debugLog()
		mouseInView = false

		//NSCursor.unhide() // NOTE: This only works when the app is frontmost, which in this case is unlikely.

		notchEffect?.mouseExited(at: notchLocation(with: event))
	}
}



