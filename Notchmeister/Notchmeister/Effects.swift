//
//	Effects.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/30/21.
//

import Foundation
import QuartzCore

enum Effects: Int, CaseIterable {
	case glow
	case cylon
	case plasma
	case festive
	case radar
	
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
		}
	}
	
	func displayDescription() -> String {
		switch self {
		case .glow:
			return "Did you know that the underside of a notch is shiny?\n\n⚠️ Works best in Dark Mode."
		case .cylon:
			return "By your command."
		case .plasma:
			return "WARNING: Your mouse can break down the magnetic containment field that keeps the M1‘s power in check!"
		case .festive:
			return "Let your Mac celebrate the holidays the best way it can—in binary.\n\n01101100 01101111 01101100"
		case .radar:
			return "Notchmeister’s patented Nano Radar lets you know exactly where your mouse has gone."
		}
	}

	func notchEffect(with parentLayer: CALayer) -> NotchEffect {
		switch self {
		case .glow:
			return GlowEffect(with: parentLayer)
		case .cylon:
			return CylonEffect(with: parentLayer)
		case .plasma:
			return PlasmaEffect(with: parentLayer)
		case .festive:
			return FestiveEffect(with: parentLayer)
		case .radar:
			return RadarEffect(with: parentLayer)
		}
	}
	
}
