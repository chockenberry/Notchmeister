//
//	Effects.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/30/21.
//

import AppKit
import QuartzCore

enum Effects: Int, CaseIterable {
	case glow
	case cylon
	case plasma
	case festive
	case radar
	case expando
#if DEBUG
	case dice
#endif
#if DEBUG
	case portal
#endif

	func displayName() -> String {
		switch self {
		case .glow:
			return "Glow"
		case .cylon:
			return "Cylon"
		case .plasma:
			return "Plasma Leak"
		case .festive:
			return "Festive"
		case .radar:
			return "Nano Radar"
		case .expando:
			return "Expando"
#if DEBUG
		case .dice:
			return "Fusion Dice"
#endif
#if DEBUG
		case .portal:
			return "Portal"
#endif
		}
	}
	
	func displayDescription() -> String {
		switch self {
		case .glow:
			return "A cursor will light your way.\n\n⚠️ Works best in Dark appearance."
		case .cylon:
			return "By your command.\n\nAnd don‘t get too close."
		case .plasma:
			return "WARNING: A mouse can break down the magnetic containment field that keeps Apple Silicon's power in check!"
		case .festive:
			return "Let your Mac celebrate the holidays the best way it can—in binary.\n\n01101100 01101111 01101100"
		case .radar:
			return "Notchmeister’s patented Nano Radar lets you know exactly where your mouse has gone."
		case .expando:
			return "Bigger is better, right?\n\n⚠️ Works best in Light appearance."
#if DEBUG
		case .dice:
			return "Apple's expertise with silicon is not only with the die, but also the dice.\n\n☢️ AVOID EYE OR SKIN EXPOSURE"
#endif
#if DEBUG
		case .portal:
			return "Activate Macintosh Interdimensional Computation Extension (MICE)."
#endif
		}
	}

	func notchEffect(with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) -> NotchEffect {
		switch self {
		case .glow:
			return GlowEffect(with: parentLayer, in: parentView, of: parentWindow)
		case .cylon:
			return CylonEffect(with: parentLayer, in: parentView, of: parentWindow)
		case .plasma:
			return PlasmaEffect(with: parentLayer, in: parentView, of: parentWindow)
		case .festive:
			return FestiveEffect(with: parentLayer, in: parentView, of: parentWindow)
		case .radar:
			return RadarEffect(with: parentLayer, in: parentView, of: parentWindow)
		case .expando:
			return ExpandoEffect(with: parentLayer, in: parentView, of: parentWindow)
#if DEBUG
		case .dice:
			return DiceEffect(with: parentLayer, in: parentView, of: parentWindow)
#endif
#if DEBUG
		case .portal:
			return PortalEffect(with: parentLayer, in: parentView, of: parentWindow)
#endif
		}
	}
	
}
