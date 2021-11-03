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
					if let filter = CIFilter(name: "CIGaussianBlur") {
						let blurScale: CGFloat = 10
						
						filter.setDefaults()
						filter.setValue(ciImage, forKey: kCIInputImageKey)
						filter.setValue(blurScale, forKey: kCIInputRadiusKey)
						
						let context = CIContext(options: nil)
						if let filteredCiImage = filter.outputImage {
							if let sublayerCgImage = context.createCGImage(filteredCiImage, from: filteredCiImage.extent) {
								let sublayerSize = CGSize(width: sublayerCgImage.width, height: sublayerCgImage.height)
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

