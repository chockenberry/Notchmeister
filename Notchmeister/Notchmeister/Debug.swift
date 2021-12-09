//
//  Debug.swift
//
//  Created by Craig Hockenberry on 10/4/19.


//  Usage:
//
//		SplineReticulationManager.swift:
//
//		func reticulationFunction() -> Float {
//			debugLog()										// prints "2019-10-04 11:52:28 SplineReticulationManager: reticulationFunction() called"
//
//			let splineCount = Int.random(in: 0...1000)
//  		debugLog("reticulating \(splineCount) splines")	// prints "2019-10-04 11:52:28 SplineReticulationManager: reticulationFunction() reticulating 123 splines"
//
//			return debugResult(Float.random(in: 0...1))		// prints "2019-10-04 11:52:28 SplineReticulationManager: reticulationFunction() returned: 0.12345"
//		}


import Foundation

func releaseLog(_ message: String = "called", file: String = #file, function: String = #function) {
	let timestamp = ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withYear, .withMonth, .withDay, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withSpaceBetweenDateAndTime])
	print("\(timestamp) \(URL(fileURLWithPath: file, isDirectory: false).deletingPathExtension().lastPathComponent): \(function) \(message)")
}

func debugLog(_ message: String = "called", file: String = #file, function: String = #function) {
	#if DEBUG
		let timestamp = ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withYear, .withMonth, .withDay, .withDashSeparatorInDate, .withTime, .withColonSeparatorInTime, .withSpaceBetweenDateAndTime])
		print("\(timestamp) \(URL(fileURLWithPath: file, isDirectory: false).deletingPathExtension().lastPathComponent): \(function) \(message)")
	#endif
}

@discardableResult
func debugResult<T>(_ result: T, file: String = #file, function: String = #function) -> T {
	debugLog("returned: \(result)", file: file, function: function)
	return result
}

#if true
	
// weed out NSLog usage
@available(iOS, deprecated: 1.0, message: "Convert to debugLog")
public func NSLog(_ format: String, _ args: CVarArg...)
{
}
	
#endif
