//
//  Defaults.swift
//  Notchmeister
//
//  Created by Chris Parrish on 10/30/21.
//

import Foundation

// This is very rudimentary and rigid
// I'm sure a treatment with protocols and generics
// that extends NSUserDefaults would be nicer

enum Defaults : String
{
    case debugDrawingEnabled
    case fakeNotchEnabled
    case notchOutlineEnabled
    case notchFillEnabled
    
    static func register() {
        UserDefaults.standard.register(defaults: [
            Defaults.debugDrawingEnabled.rawValue: false,
            Defaults.fakeNotchEnabled.rawValue: false,
            Defaults.notchOutlineEnabled.rawValue : false,
            Defaults.notchFillEnabled.rawValue: false,
        ])
    }
    
    static var shouldDebugDrawing: Bool {
        get { UserDefaults.standard.bool(forKey: Defaults.debugDrawingEnabled.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Defaults.debugDrawingEnabled.rawValue)}
    }
    
    static var shouldFakeNotch: Bool {
        get { UserDefaults.standard.bool(forKey: Defaults.fakeNotchEnabled.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Defaults.fakeNotchEnabled.rawValue)}
    }
    
    static var shouldDrawNotchOutline: Bool {
        get { UserDefaults.standard.bool(forKey: Defaults.notchOutlineEnabled.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Defaults.notchOutlineEnabled.rawValue)}
    }
    
    static var shouldDrawNotchFill: Bool {
        get { UserDefaults.standard.bool(forKey: Defaults.notchFillEnabled.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Defaults.notchFillEnabled.rawValue)}
    }
}