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
	case effectSelection

	static var registered = false
	
	static func register() {
		if !registered	 {
			UserDefaults.standard.register(defaults: [
				Defaults.debugDrawingEnabled.rawValue: false,
				Defaults.fakeNotchEnabled.rawValue: true,
				Defaults.notchOutlineEnabled.rawValue : false,
				Defaults.notchFillEnabled.rawValue: true,
				Defaults.effectSelection.rawValue: Effects.festive.rawValue,
			])
			registered = true
		}
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
	
	// TODO: This should eventually be an enumeration
	static var selectedEffect: Int {
		get { UserDefaults.standard.integer(forKey: Defaults.effectSelection.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Defaults.effectSelection.rawValue)}
	}

}
