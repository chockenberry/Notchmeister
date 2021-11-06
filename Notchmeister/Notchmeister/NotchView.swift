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
	
	var sublayer: CALayer?
    var notchOutlineLayer: CAShapeLayer?
    var cyclonEffect: CylonEffect?
	
	let context = CIContext(options: nil)

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
                cyclonEffect = createCylonEffect()
                cyclonEffect?.startAnimation()
                
                createOutlineLayer()

				// create a sublayer that will follow mouse movements
				sublayer = CALayer()
				if let sublayer = sublayer {
					let dimension: CGFloat = 20
					sublayer.bounds = CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension))
					sublayer.masksToBounds = false
					if Defaults.shouldDebugDrawing {
						sublayer.backgroundColor = NSColor.systemBlue.cgColor
					}
					else {
						sublayer.backgroundColor = NSColor.clear.cgColor
					}
					sublayer.contentsScale = layer.contentsScale
					sublayer.position = .zero
					sublayer.opacity = 0
					
					layer.addSublayer(sublayer)
				}
			}
		}
		else {
			sublayer?.removeFromSuperlayer()
			sublayer = nil
			
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
    
    //MARK: - NSResponder
    
	override func mouseEntered(with event: NSEvent) {
		debugLog()
		mouseInView = true
		
		//NSCursor.hide() // NOTE: This only works when the app is frontmost, which in this case is unlikely.

		if let sublayer = sublayer {
			let cursor = NSCursor.current
			let cursorSize = cursor.image.size
			let hotSpot = cursor.hotSpot
			
			if let glowBaseImage = NSImage(named: "glowBase") {
				let glowBaseSize = glowBaseImage.size
				
				// record the hot spot in normalized coordinates relative to the center of the cursor since that's where we're scaling the image from
				let normalizedHotSpotPoint = NSPoint(x: (hotSpot.x / cursorSize.width) - 0.5, y: (hotSpot.y / cursorSize.height) - 0.5)
				
				//var proposedRect = CGRect(origin: .zero, size: cursorSize)
				var proposedRect = CGRect(origin: .zero, size: glowBaseSize)
				//if let cgImage = cursor.image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) {
				if let cgImage = glowBaseImage.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) {
					let ciImage = CIImage(cgImage: cgImage)
					// NOTE: The image processing here will be more complicated, this is just a placeholder.
					if let filter = CIFilter(name: "CIDiscBlur") {
						let blurScale: CGFloat = 10
						
						// glowBaseImage = 20 x 20 pt
						// ciImage.extent = 40 x 40 @ 0,0
						// blurScale = 10, filteredCiImage = 100 x 100 @ -30, -30, sublayerSize = 50 x 50 pt
						// blurScale = 5, filteredCiImage = 70 x 70 @ -15, -15, sublayerSize = 35 x 35 pt
						// blurScale = 1, filteredCiImage = 46 x 46 @ -3, -3, sublayerSize = 23 x 23 pt

						filter.setDefaults()
						filter.setValue(ciImage, forKey: kCIInputImageKey)
						filter.setValue(blurScale, forKey: kCIInputRadiusKey)
						
						if let filteredCiImage = filter.outputImage {
							debugLog("filteredCiImage.extent = \(filteredCiImage.extent)")
							if let sublayerCgImage = context.createCGImage(filteredCiImage, from: filteredCiImage.extent) {
								let scale = sublayer.contentsScale
								let sublayerSize = CGSize(width: CGFloat(sublayerCgImage.width) / scale, height: CGFloat(sublayerCgImage.height) / scale)
								//debugLog("sublayerSize = \(sublayerSize)") //
								sublayer.bounds = CGRect(origin: .zero, size: sublayerSize)
								sublayer.anchorPoint = CGPoint(x: 0.5 + (normalizedHotSpotPoint.x / blurScale), y: 0.5 + (normalizedHotSpotPoint.y / blurScale))
								sublayer.contents = sublayerCgImage
							}
						}
					}
				}
			}
			sublayer.opacity = 1
		}
	}
	
	override func mouseMoved(with event: NSEvent) {
		if mouseInView {
			if let sublayer = sublayer {
				let locationInWindow = event.locationInWindow
				let locationInView = self.convert(locationInWindow, from: nil)
				//debugLog("point = \(locationInView)")
				CATransaction.withActionsDisabled {
					sublayer.position = locationInView
				}
			}
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		debugLog()
		mouseInView = false

		//NSCursor.unhide() // NOTE: This only works when the app is frontmost, which in this case is unlikely.
		
		if let sublayer = sublayer {
			sublayer.opacity = 0
		}
	}
}



