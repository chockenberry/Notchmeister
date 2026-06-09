//
//  SpeechSynthesizer.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 6/1/26.
//

import Foundation
import AVFoundation

public extension Notification.Name {
	static let speechSynthesizerLevelDidChange = Notification.Name("speechSynthesizerLevelDidChange")
}

public final class SpeechSynthesizer: NSObject, @unchecked Sendable {
	
	public static let shared = SpeechSynthesizer()

	private let audioEngine = AVAudioEngine()
	private let playerNode = AVAudioPlayerNode()
	private let speechSynthesizer = AVSpeechSynthesizer()
	
	public var voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-GB.Daniel")
	public var rate: Float = 0.55
	public var pitchMultiplier: Float = 1.4

	private(set) var isSpeaking: Bool = false
	private(set) var level: Float = 0.0

#if DEBUG && true
	private var sampleCount = 0
	private var maxLevel: Float = -Float.infinity
	private var minLevel: Float = Float.infinity
#endif
	
	public override init() {
		super.init()
		
		// NOTE: We can't use the AVSpeechSynthesizerDelegate methods to detect when speech is active.
		// When using write() to feed AVAudioBuffer to the playerNode, the methods don't track the state
		// of the player; instead we track the state of the buffers and scheduling in the player to maintain
		// a consistent isSpeaking state. A side effect of this is that there's no way to stop speech
		// that's already in progress (it's possible, but hard to do without being glitchy).
		
		audioEngine.attach(playerNode)
		let mainMixer = audioEngine.mainMixerNode
		let mainMixerFormat = mainMixer.outputFormat(forBus: 0)
		
#if true // assume the format of the speech synthesizer buffers that we tap
		let speechSynthesizerFormat = AVAudioFormat(standardFormatWithSampleRate: 22050, channels: 1)
		self.audioEngine.connect(self.playerNode, to: mainMixer, format: speechSynthesizerFormat)
		//self.playerNode.play()
#else // don't assume the format of the buffers, run a test phrase through write() to sample it
		let utterance = AVSpeechUtterance(string: "Test")
		utterance.voice = voice
		utterance.rate = rate
		utterance.pitchMultiplier = pitchMultiplier
		utterance.volume = 1.0

		DispatchQueue.global(qos: .utility).async {
			self.speechSynthesizer.write(utterance) { buffer in
				var speechSynthesizerFormat = AVAudioFormat(standardFormatWithSampleRate: 22050, channels: 1)
				if let pcmbuffer = buffer as? AVAudioPCMBuffer {
					speechSynthesizerFormat = pcmbuffer.format
				}
				
				self.audioEngine.connect(self.playerNode, to: mainMixer, format: speechSynthesizerFormat)
				//self.playerNode.play()
			}
		}
#endif

		mainMixer.installTap(onBus: 0, bufferSize: 4096, format: mainMixerFormat) { (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
			if !self.playerNode.isPlaying {
				self.playerNode.play()
			}
			
			guard let channelData = buffer.floatChannelData else { return }
			let channelDataValue = channelData[0]
			let frameLength = UInt(buffer.frameLength)
			
#if false // process all channelData in one pass
			// calculate RMS
			var sum: Float = 0
			for i in 0..<Int(frameLength) {
				sum += channelDataValue[i] * channelDataValue[i]
			}
			let rms = sqrt(sum / Float(frameLength))
			
			// convert to Decibels
			let db = 20 * log10(rms)
			
			// db now represents the audio level (e.g., -20 dB to 0 dB)
			if db != self.level {
				self.level = db
				DispatchQueue.main.async {
					NotificationCenter.default.post(name: .speechSynthesizerLevelDidChange, object: self)
				}
			}
#else // process channelData in multiple passes
			let passes: UInt = 2
			let by: Int = Int(frameLength / passes)
			for passIndex in stride(from: 0, to: Int(frameLength), by: by) {
				//print("stride: \(passIndex) by \(by), \(passIndex) -> \(passIndex + by)")
				var sum: Float = 0
				for index in passIndex..<(passIndex + by) {
					if index < frameLength {
						sum += channelDataValue[index] * channelDataValue[index]
					}
				}
				let rms = sqrt(sum / Float(by))
				let db = 20 * log10(rms)
				if !db.isNaN {
					if db != self.level {
						self.level = db
						DispatchQueue.main.async {
							NotificationCenter.default.post(name: .speechSynthesizerLevelDidChange, object: self)
						}
					}
				}
			}
#endif
			
#if DEBUG && false
			if !self.level.isInfinite {
				self.sampleCount += 1
				if self.level > self.maxLevel {
					self.maxLevel = self.level
				}
				if self.level < self.minLevel {
					self.minLevel = self.level
				}
				debugLog("installTap: \(String(format: "%.2f", AVAudioTime.seconds(forHostTime: time.hostTime))) - sample: \(self.sampleCount), frameLength: \(frameLength), level: \(self.level) (\(self.minLevel) -> \(self.maxLevel)) dB")
			}
			else {
				debugLog("installTap: no level")
				self.sampleCount = 0
				self.maxLevel = -Float.infinity
				self.minLevel = Float.infinity
			}
#endif
		}
		
		do {
			try audioEngine.start()
		}
		catch {
			debugLog("failed to start audioEngine: \(error)")
		}
	}
	
	public func startMonitoring() {
		if !audioEngine.isRunning {
			debugLog("resuming")
			do {
				try audioEngine.start()
			}
			catch {
				debugLog("failed to start audioEngine: \(error)")
			}
		}
	}

	public func stopMonitoring() {
		if audioEngine.isRunning {
			debugLog("pausing")
			playerNode.pause()
			audioEngine.pause()
		}
	}

	public func speak(_ text: String) {
		guard !isSpeaking else { return }

		let utterance = AVSpeechUtterance(string: text)
		utterance.voice = voice
		utterance.rate = rate
		utterance.pitchMultiplier = pitchMultiplier
		utterance.volume = 1.0

		isSpeaking = true
		
		DispatchQueue.global(qos: .utility).async {
			self.speechSynthesizer.write(utterance) { buffer in
				if let pcmBuffer = buffer as? AVAudioPCMBuffer {
					var isFinalBuffer = false
					if pcmBuffer.frameLength == 0 {
						isFinalBuffer = true
					}
					// NOTE: The playerNode schedules the buffer on its own render thread, but it gets glitchy if a
					// non-main thread is used to initiate the operation. Also, we're already running on the main thread
					// at this point, but need to capture isFinalBuffer to know when reset to isSpeaking.
					DispatchQueue.main.async { [isFinalBuffer] in
						self.playerNode.scheduleBuffer(pcmBuffer, at: nil, options: [], completionCallbackType: .dataPlayedBack) { callbackType in
							if isFinalBuffer {
								self.isSpeaking = false
							}
						}
					}
				}
			}
		}

	}
	
}
