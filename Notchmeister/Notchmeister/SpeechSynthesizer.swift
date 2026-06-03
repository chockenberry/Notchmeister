//
//  SpeechSynthesizer.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 6/1/26.
//

import Foundation
import AVFoundation

public final class SpeechSynthesizer: NSObject, @unchecked Sendable {
	
	public static let shared = SpeechSynthesizer()

	private let audioEngine = AVAudioEngine()
	private let playerNode = AVAudioPlayerNode()
	private let speechSynthesizer = AVSpeechSynthesizer()
	
	public var voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-GB.Daniel")
	public var rate: Float = 0.55
	public var pitchMultiplier: Float = 1.35

	private(set) var isSpeaking: Bool = false
	private(set) var currentLevel: Float = 0.0

#if DEBUG
	private var sampleCount = 0
	private var maxLevel: Float = -Float.infinity
	private var minLevel: Float = Float.infinity
#endif
	
	public override init() {
		super.init()
		
		// NOTE: We can't use the AVSpeechSynthesizerDelegate methods to detect when speech is active.
		// When using write() to feed AVAudioBuffer to the playerNode, the methods don't track the state
		// of the player, so we track the state of the buffers and scheduling in the player to maintain
		// a consistent isSpeaking state. A side effect of this is that there's no way to stop speech
		// that's already in progress.
		
		audioEngine.attach(playerNode)
		let mainMixer = audioEngine.mainMixerNode
		let mainMixerFormat = mainMixer.outputFormat(forBus: 0)
		
#if false
		let speechSynthesizerFormat = AVAudioFormat(standardFormatWithSampleRate: 22050, channels: 1)
		self.audioEngine.connect(self.playerNode, to: mainMixer, format: speechSynthesizerFormat)
		self.playerNode.play()
#else

		let utterance = AVSpeechUtterance(string: "Test")
		utterance.voice = voice //AVSpeechSynthesisVoice(language: "en-US")!
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
				self.playerNode.play()
			}
		}
#endif

		mainMixer.installTap(onBus: 0, bufferSize: 4096, format: mainMixerFormat) { (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
			guard let channelData = buffer.floatChannelData else { return }
			let channelDataValue = channelData[0]
			let frameLength = UInt(buffer.frameLength)
			
			// Calculate RMS
			var sum: Float = 0
			for i in 0..<Int(frameLength) {
				sum += channelDataValue[i] * channelDataValue[i]
			}
			let rms = sqrt(sum / Float(frameLength))
			
			// Convert to Decibels
			let db = 20 * log10(rms)
			
			// db now represents the live audio level (e.g., -20 dB to 0 dB)
			if (sum > 0.0) {
#if DEBUG
				self.sampleCount += 1
				if db > self.maxLevel {
					self.maxLevel = db
				}
				if db < self.minLevel {
					self.minLevel = db
				}
				debugLog("\(String(format: "%.2f", AVAudioTime.seconds(forHostTime: time.hostTime))) - sample: \(self.sampleCount), sum: \(sum), frameLength: \(frameLength), rms: \(rms), level: \(db) (\(self.minLevel) -> \(self.maxLevel)) dB")
#endif
			}
			else {
#if DEBUG
				self.sampleCount = 0
				self.maxLevel = -Float.infinity
				self.minLevel = Float.infinity
#endif
			}
			self.currentLevel = db
		}
		
		do {
			try audioEngine.start()
		}
		catch {
			debugLog("failed to start audioEngine: \(error)")
		}
	}

	public func speak(_ text: String) {
		guard !isSpeaking else { return }

		let utterance = AVSpeechUtterance(string: text)
		utterance.voice = voice //AVSpeechSynthesisVoice(language: "en-US")!
		utterance.rate = rate
		utterance.pitchMultiplier = pitchMultiplier
		utterance.volume = 1.0

#if false
		speechSynthesizer.speak(utterance)
#else
		isSpeaking = true
		
		speechSynthesizer.write(utterance) { buffer in
			if let pcmBuffer = buffer as? AVAudioPCMBuffer {
				//debugLog("\(pcmBuffer.frameLength) frames of \(pcmBuffer.frameCapacity)")
				var isFinalBuffer = false
				if pcmBuffer.frameLength == 0 {
					debugLog("isSpeaking: done write, isFinalBuffer = true")
					isFinalBuffer = true
				}
				DispatchQueue.main.async { [isFinalBuffer] in
					self.playerNode.scheduleBuffer(pcmBuffer, at: nil, options: [], completionCallbackType: .dataPlayedBack) { callbackType in
						if isFinalBuffer {
							self.isSpeaking = false
							debugLog("isSpeaking: isFinalBuffer, isSpeaking = \(self.isSpeaking)")
						}
					}
				}
			}
		}
#endif

	}
	
}
