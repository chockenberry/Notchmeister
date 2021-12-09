//
//  FakeNotchView.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/15/21.
//

import AppKit

class FakeNotchView: NSView {
	
	@IBOutlet var notchTextField: NSTextField!
	
	var notchLayer: CAShapeLayer?
	
	override func updateLayer() {
		guard let notchLayer = notchLayer else { return }
		
		notchLayer.fillColor = Defaults.shouldDrawNotchFill ? NSColor.black.cgColor : NSColor.clear.cgColor
		notchLayer.strokeColor = Defaults.shouldDrawNotchOutline ? NSColor.white.cgColor : NSColor.clear.cgColor
		notchLayer.lineWidth = 2.0
	}

	override func viewDidMoveToSuperview() {
		if self.superview != nil {
			// create a layer hosting view
			wantsLayer = true
			
			configureView()
			createNotchLayer()
		}
	}
	
	private func configureView() {
		notchTextField?.isHidden = Defaults.shouldDrawNotchText == false
	}
	
	private func createNotchLayer() {
		guard let layer = layer else { return }

		layer.masksToBounds = false
		
		let notchOutlineLayer = CAShapeLayer.notchOutlineLayer(for: bounds.size, flipped: isFlipped)
				
		notchOutlineLayer.masksToBounds = false
		
		notchOutlineLayer.anchorPoint = .zero
		notchOutlineLayer.autoresizingMask = [.layerHeightSizable, .layerWidthSizable]
		layer.addSublayer(notchOutlineLayer)
		
		notchLayer = notchOutlineLayer
	}

}
