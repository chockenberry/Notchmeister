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

enum Defaults : String, CaseIterable
{
    case debugDrawingEnabled
    case fakeNotchEnabled
	case largeFakeNotchEnabled
	case deactivateFakeNotchEnabled
    case notchOutlineEnabled
    case notchFillEnabled
	case notchTextEnabled
	case effectSelection
	case hideDockIconEnabled
	case alternateDiceEnabled

	static var registered = false
	
	static func register() {
		if !registered	 {
			UserDefaults.standard.register(defaults: [
				Defaults.debugDrawingEnabled.rawValue: false,
				Defaults.fakeNotchEnabled.rawValue: true,
				Defaults.largeFakeNotchEnabled.rawValue: false,
				Defaults.deactivateFakeNotchEnabled.rawValue: true,
				Defaults.notchOutlineEnabled.rawValue : false,
				Defaults.notchFillEnabled.rawValue: true,
				Defaults.notchTextEnabled.rawValue: true,
				Defaults.effectSelection.rawValue: Effects.festive.rawValue,
				Defaults.hideDockIconEnabled.rawValue: false,
				Defaults.alternateDiceEnabled.rawValue: false,
			])
			registered = true
		}
	}
    
	static func reset() {
		if registered {
			for aCase in allCases {
				UserDefaults.standard.removeObject(forKey: aCase.rawValue)
			}
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

	static var shouldLargeFakeNotch: Bool {
		get { UserDefaults.standard.bool(forKey: Defaults.largeFakeNotchEnabled.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Defaults.largeFakeNotchEnabled.rawValue)}
	}

	static var shouldDeactivateFakeNotch: Bool {
		get { UserDefaults.standard.bool(forKey: Defaults.deactivateFakeNotchEnabled.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Defaults.deactivateFakeNotchEnabled.rawValue)}
	}

    static var shouldDrawNotchOutline: Bool {
        get { UserDefaults.standard.bool(forKey: Defaults.notchOutlineEnabled.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Defaults.notchOutlineEnabled.rawValue)}
    }
    
    static var shouldDrawNotchFill: Bool {
        get { UserDefaults.standard.bool(forKey: Defaults.notchFillEnabled.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Defaults.notchFillEnabled.rawValue)}
    }

	static var shouldDrawNotchText: Bool {
		get { UserDefaults.standard.bool(forKey: Defaults.notchTextEnabled.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Defaults.notchTextEnabled.rawValue)}
	}

	// the Effects enumeration's rawValue is stored here
	static var selectedEffect: Int {
		get { UserDefaults.standard.integer(forKey: Defaults.effectSelection.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Defaults.effectSelection.rawValue)}
	}

	static var shouldHideDockIcon: Bool {
		get { UserDefaults.standard.bool(forKey: Defaults.hideDockIconEnabled.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Defaults.hideDockIconEnabled.rawValue)}
	}

	static var shouldUseAlternateDice: Bool {
		get { UserDefaults.standard.bool(forKey: Defaults.alternateDiceEnabled.rawValue) }
		set { UserDefaults.standard.set(newValue, forKey: Defaults.alternateDiceEnabled.rawValue)}
	}

	static let notchlessHelp = "This Mac doesn't have a notch.\n\nThanks to Notchmeister's built-in genuine replacement notch, you can still have fun. This replacement part, like all others, doesn't quite work as original: it's shorter and the mouse doesn't disappear underneath.\n\nNote also that this notch only appears when the app is active so it doesn't interfere with other apps.\n\n"

	static let notchlessHelpIntro = "Side effects of this app include making you want a new MacBook even more than you already do. Sorry."
	static let githubHelpButton = "It‘s unlikely that you‘ll need help with Notchmeister, but if you do, get in touch with us on GitHub. If you think the app needs a fix or new feature, this is the place to do it."

	static let notchedHelp = "Congratulations, you have a notch!\n\n"
	
	static let gitHubUrl = URL(string: "https://github.com/chockenberry/Notchmeister")!

}
