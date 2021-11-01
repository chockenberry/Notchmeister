//
//  NSBezierPath.swift
//  Notchmeister
//
//  Created by Chris Parrish on 10/31/21.
//

import AppKit

extension NSBezierPath {

    class func notchPath(rect: NSRect) -> NSBezierPath {
                
        let radius = 8.0
        let path = NSBezierPath()

        path.move(to: NSPoint(x: rect.minX, y: rect.maxY))
        path.line(to: NSPoint(x: rect.minX, y: rect.minY + radius))
        path.appendArc(from: NSPoint(x: rect.minX, y: rect.minY), to: NSPoint(x: rect.minX + radius, y: rect.minY), radius: radius)
        path.line(to: NSPoint(x: rect.maxX - radius, y: rect.minY))
        path.appendArc(from: NSPoint(x: rect.maxX, y: rect.minY), to: NSPoint(x: rect.maxX, y: rect.minY + radius), radius: radius)
        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))

        
        return path
    }
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: points[0])
            case .lineTo: path.addLine(to: points[0])
            case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath: path.closeSubpath()
            @unknown default:
                print("Unknown NSBezierPath element type.")
                break
            }
        }
        return path
    }

}
