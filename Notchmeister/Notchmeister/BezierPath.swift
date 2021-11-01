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
        
        path.appendArc(withCenter: NSPoint(x: rect.minX, y: rect.maxY - radius), radius: radius, startAngle: 90, endAngle: 0, clockwise: true)
        path.appendArc(withCenter: NSPoint(x: rect.minX + 2 * radius, y: rect.minY + radius), radius: radius, startAngle: 180, endAngle: 270)
        path.appendArc(withCenter: NSPoint(x: rect.maxX - 2 * radius, y: rect.minY + radius), radius: radius, startAngle: 270, endAngle: 0)
        path.appendArc(withCenter: NSPoint(x: rect.maxX, y: rect.maxY - radius), radius: radius, startAngle: 180, endAngle: 90, clockwise: true)
        
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
