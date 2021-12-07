//
//  Notch.swift
//  Notchmeister
//
//  Created by Chris Parrish on 11/6/21.
//
//
// Class extensions useful for Notched display adornments and interactions

import AppKit

//MARK: - NSScreen Extensions

extension NSScreen {

	/// Returns true if there are one or more screens with a notch.
	static var hasNotchedScreen: Bool {
		let notchedScreens = NSScreen.screens.filter { $0.notchArea != nil }
		return (notchedScreens.count != 0)
	}

    /// All of the attached screens that have notches. Could include displays
    /// without a physical notch if Defaults.shouldFakeNotch is true
    static var notchedScreens: [NSScreen] {
        // Always favor physical screens with a notch, but return all screens if we're faking notches.
        if Defaults.shouldFakeNotch {
            return NSScreen.screens
        } else {
            return NSScreen.screens.filter { $0.notchArea != nil }
        }
    }
    
    /// Returns the area a notch covers on this screen or a similar area
    /// on screens without a notch if Defaults.shouldFakeNotch is true.
    /// Otherwise returns nil.
    var notchRect: NSRect? {
        if let notchArea = self.notchArea {
            return notchArea
        }
        else if Defaults.shouldFakeNotch {
            return self.fakeNotchArea
        }
        else {
            return nil
        }
    }
    
    /// The rectangular area the notch covers on this screen, or nil
    /// if there is no notch on this screen. A portion of this area near
    /// the bottom corners is still visible screen because the physical notch
    /// has round corners.
    var notchArea: NSRect? {
        guard let topLeft = topLeftSafeArea, let topRight = topRightSafeArea else {
            return nil
        }
        
        let width = topRight.minX - topLeft.maxX
        let height = max(topRight.height, topLeft.height)
        let x = topLeft.maxX
        let y = min(topLeft.minY, topRight.minY)

        return NSRect(x: x, y: y, width: width, height: height)
    }
    

	/// An area similar to what the notch would cover even if this screen
    /// does not have a notch.
    var fakeNotchArea: NSRect {
        let screenFrame = self.frame
        let visibleFrame = self.visibleFrame
        
		let fakeNotchSize: CGSize
		if Defaults.shouldLargeFakeNotch {
			fakeNotchSize = NSSize(width:220, height:38)
		}
		else {
			fakeNotchSize = NSSize(width:220, height:screenFrame.maxY - visibleFrame.maxY)
		}

        let x = self.frame.midX - (fakeNotchSize.width / 2)
        let y = self.frame.maxY - fakeNotchSize.height
        return NSRect(origin:NSPoint(x: x, y: y), size:fakeNotchSize)
    }
    
    /// On a notched screen, the area adjacent to the left side
    /// of the notch, otherwise nil.
    /// Equivalent to auxiliaryTopLeftArea on macOS 12 or later
    var topLeftSafeArea: NSRect? {
        if #available(macOS 12, *) {
            return self.auxiliaryTopLeftArea
        }
        else {
            return nil
        }
    }
    
    /// On a notched screen, the area adjacent to the right side
    /// of the notch, otherwise nil.
    /// Equivalent to auxiliaryTopRightArea on macOS 12 or later
    var topRightSafeArea: NSRect? {
        if #available(macOS 12, *) {
            return self.auxiliaryTopRightArea
        }
        else {
            return nil
        }
    }
}

//MARK: - CAShapeLayer Extensions

extension CAShapeLayer {
    
    /// Creates a shape layer with a path that matches the shape of the
    /// display notch.
    /// - Parameter size: the dimensions of the notch area
    /// - Parameter flipped: the path is flipped (to match a parent layer)
    /// - Returns: shape layer with a path that follows the contour of the
    /// display notch.
	class func notchOutlineLayer(for size: NSSize, flipped: Bool = false) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = NSBezierPath.notchPath(size: size)
		
		if (flipped) {
			var flipTransform = AffineTransform(scaleByX: 1, byY: -1)
			flipTransform.translate(x: 0, y: -size.height)
			path.transform(using: flipTransform)
		}

        layer.path = path.cgPath
        layer.bounds.size = size
        
        return layer
    }
    
}

// MARK: - NSBezierPath Extensions

extension NSBezierPath {
    
    /// Returns a path that matches the display notch with the given area
    /// - Parameter size: the dimensions of the notch path
    /// - Returns: the notch outline path, with the origin at the bottom-left
    class func notchPath(size: NSSize) -> NSBezierPath {
        
        // default coordinate space is flipped so (0,0) is lower-left
        
		//let radius: CGFloat = .notchLowerRadius
        let path = NSBezierPath()

        path.move(to: NSPoint(x: 0, y: size.height))
        path.line(to: NSPoint(x: 0, y: .notchLowerRadius))
        path.appendArc(from: .zero, to: NSPoint(x: .notchLowerRadius, y: 0), radius: .notchLowerRadius)
        path.line(to: NSPoint(x: size.width - .notchLowerRadius, y: 0))
        path.appendArc(from: NSPoint(x: size.width, y: 0), to: NSPoint(x: size.width, y: .notchLowerRadius), radius: .notchLowerRadius)
        path.line(to: NSPoint(x: size.width, y: size.height))

        return path
    }
}

extension CGFloat {
	
	public static let notchLowerRadius = 8.0
	
}
