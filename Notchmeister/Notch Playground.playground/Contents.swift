//: A Cocoa based Playground to present user interface

import AppKit
import PlaygroundSupport
import Darwin

Defaults.shouldFakeNotch = true
Defaults.shouldDrawNotchOutline = true
Defaults.shouldDrawNotchFill = true

let nibFile = NSNib.Name("MyView")
var topLevelObjects : NSArray?

Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)

let view = (topLevelObjects as! Array<Any>).first {
    $0 is NSView
} as! NSView

view.layer?.backgroundColor = NSColor.darkGray.cgColor
// Present the view in Playground
PlaygroundPage.current.liveView = view


// Notch

let notchSize = NSScreen.main!.fakeNotchArea.size
let notchOrigin = NSPoint(x: 40, y: view.frame.size.height - notchSize.height - 12)
let notchView = NotchView(frame: NSRect(origin: notchOrigin, size: notchSize))
view.addSubview(notchView)


// Cylon Eye

let cylonOrigin = NSPoint(x: notchOrigin.x, y: notchOrigin.y - notchSize.height - 40)
let cylonFrame = NSRect(origin: cylonOrigin, size: notchSize)
let cylonView = NSView(frame: cylonFrame)
cylonView.wantsLayer = true
cylonView.layer?.backgroundColor = NSColor.black.cgColor

view.addSubview(cylonView)

// MARK: current for reference
let cylonEffect = CylonEffect(with: cylonView.layer!)

cylonEffect.redEyeLayer.position = NSPoint(x: cylonView.bounds.midX - 50, y: cylonView.bounds.midY)

// MARK:  experiemental

let eyeWidth = 20.0
let eyeHeight = 6.0
let glowHorizontalInset = -16.0
let glowVerticalInset = -20.0

let irisColor = CGColor(srgbRed: 0.9979979396, green: 0.4895141721, blue: 0.491407156, alpha: 1.0)
let glowStartColor = NSColor(srgbRed: 0.82, green: 0.22, blue: 0.19, alpha: 1.0)
let glowEndColor = glowStartColor.withAlphaComponent(0.0)

let parentLayer = cylonView.layer!

// iris
let irisLayer = CALayer()
irisLayer.backgroundColor = irisColor

irisLayer.bounds = NSRect(origin: .zero, size: NSSize(width: eyeWidth, height: eyeHeight))
irisLayer.position = NSPoint(x: parentLayer.bounds.midX + 50, y: parentLayer.bounds.midY)

irisLayer.cornerRadius = eyeHeight / 2.0
parentLayer.addSublayer(irisLayer)


// glow
let glowLayer = CAGradientLayer()

glowLayer.type = .radial
glowLayer.colors = [glowStartColor.cgColor, glowEndColor.cgColor]
glowLayer.locations = [0,1]
glowLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
glowLayer.endPoint = CGPoint(x: 1,y: 1)

var glowBounds = irisLayer.bounds.insetBy(dx: glowHorizontalInset, dy: glowVerticalInset)
glowBounds.origin = .zero
glowLayer.bounds = glowBounds
glowLayer.position = NSPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.midY )

parentLayer.insertSublayer(glowLayer, below: irisLayer)

// uncomment to composite layers

//irisLayer.position = NSPoint(x: parentLayer.bounds.midX, y: parentLayer.bounds.midY )
