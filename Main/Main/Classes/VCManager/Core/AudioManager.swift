//
//  VoicePlayManager.swift
//  MainProject
//
//  Created by 陈文强 on 16/6/23.
//  Copyright © 2016年 CWQ. All rights reserved.
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif
import AVFoundation
import AudioToolbox



//#MARK: - ---AudioRecordManager---
public typealias AudioRecordPrepareCompete = () -> Bool
public typealias AudioRecordComplete       = () -> ()
public typealias AudioRecordProgress       = (Double) -> ()
public typealias AudioRecordPeakPower      = (Double) -> ()

open class AudioRecordManager: NSObject {
    // If the current time > maxTime, callback complete
    open var maxTimeStopRecorderCompletion: AudioRecordComplete?
    // Call when reach every record callback
    open var recordProgress: AudioRecordProgress?
    // Call when reach power
    open var peakPowerForChannel: AudioRecordPeakPower?
    
    // Path for record
    open var recordPath: String?
    // The record duration after record finish
    open var recordDuration: TimeInterval = 0
    // Current record time
    open var currentTime: TimeInterval?
    
    // check if recording
    open var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    // To control the max time
    open var maxRecordTime: Double = 60.0
    
    fileprivate var timer: Timer?
    fileprivate var isPause: Bool?
    fileprivate var recorder: AVAudioRecorder?
    
    deinit {
        self.recordPath = nil
//        self.stopRecording(<#T##complete: AudioRecordComplete?##AudioRecordComplete?##() -> ()#>)
    }
    
    open func prepareRecording(_ filePath: String?, compete: AudioRecordPrepareCompete?) {
        guard filePath?.characters.count > 0 else {
            return
        }
        
        recordPath = nil
        recordDuration = 0
        currentTime = 0
        
        weak var wSelf = self
        DispatchQueue.global().async {
            wSelf?.isPause = false
            
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try session.setActive(true)
            }catch {
                return
            }
                
            #endif
            
            var recordSetting = [String: AnyObject]()
            
            recordSetting[AVNumberOfChannelsKey] = 1 as AnyObject?
            
            #if os(OSX)
            recordSetting[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
            recordSetting[AVSampleRateKey] = 16000.0
            #elseif os(iOS)
            recordSetting[AVFormatIDKey] = Int(kAudioFormatAppleLossless) as AnyObject?
            recordSetting[AVSampleRateKey] = 44100.0 as AnyObject?
            recordSetting[AVEncoderAudioQualityKey] = AVAudioQuality.low.rawValue as AnyObject?
            #endif
    
            if (wSelf != nil) {
                wSelf?.recordPath = filePath;
                
                if (wSelf?.recorder != nil) {
                    wSelf?.cancelRecording()
                } else {
                    let url = URL(fileURLWithPath: filePath!)
                    do {
                        let recorder = try AVAudioRecorder(url: url, settings: recordSetting)
                        recorder.delegate = wSelf
                        recorder.prepareToRecord()
                        recorder.isMeteringEnabled = true
                        self.recorder = recorder
                    }catch {
                        return
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    if let enable = compete?() {
                        if enable == false {
                            wSelf?.cancelledDelete(nil)
                        }
                    }
                })
            }
        }
    }
    
    open func startRecording(_ complete: AudioRecordComplete?) {
        if recorder?.record() == true {
            // Begin timer
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AudioRecordManager.updateMeters), userInfo: nil, repeats: true)
            
            DispatchQueue.main.async(execute: {
                complete?()
            })
        }
    }
    
    open func pauseRecording(_ complete: AudioRecordComplete?) {
        isPause = true
        recorder?.pause()
        
        if recorder?.isRecording == false {
            DispatchQueue.main.async(execute: {
                complete?()
            })
        }
    }
    
    open func resumeRecording(_ complete: AudioRecordComplete?) {
        isPause = false
        
        if recorder?.record() == true {
            DispatchQueue.main.async(execute: {
                complete?()
            })
        }
    }
    
    open func stopRecording(_ complete: AudioRecordComplete?) {
        isPause = false
        stopRecording()
        getVoiceDuration()
        DispatchQueue.main.async(execute: {
            complete?()
        })
    }
    
    open func cancelledDelete(_ complete: AudioRecordComplete?) {
        isPause = false
        stopRecording()
        
        if let path = self.recordPath {
            // 删除目录下文件
            let mgr = FileManager.default
            if mgr.fileExists(atPath: path) == true {
                do {
                    try mgr.removeItem(atPath: path)
                }catch {
                    DispatchQueue.main.async(execute: {
                        complete?()
                    })
                }
            }
            
            DispatchQueue.main.async(execute: {
                complete?()
            })
        }else {
            DispatchQueue.main.async(execute: {
                complete?()
            })
        }
    }
}


extension AudioRecordManager {
    fileprivate func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    fileprivate func cancelRecording() {
        if recorder?.isRecording == true {
            recorder?.stop()
        }
        recorder = nil
    }
    
    fileprivate func stopRecording() {
        cancelRecording()
        resetTimer()
    }
    
    func updateMeters() {
        guard recorder != nil else {
            return
        }
        
        DispatchQueue.global().async(execute: {
            self.recorder?.updateMeters()
            
            self.currentTime = self.recorder?.currentTime
            
            if self.isPause == false {
                let progress = (self.currentTime ?? 0) / self.maxRecordTime * 1.0
                DispatchQueue.main.async(execute: {
                    self.recordProgress?(progress)
                })
            }
            
            let power = Double(self.recorder?.averagePower(forChannel: 0) ?? 0)
            let alpha = 0.015
            let value = pow(10, (alpha * power))
            
            DispatchQueue.main.async(execute: {
                self.peakPowerForChannel?(value)
            })
            
            
            if self.currentTime > self.maxRecordTime {
                self.recorder?.stop()
                
                DispatchQueue.main.async(execute: {
                    self.resetTimer()
                    self.maxTimeStopRecorderCompletion?()
                })
            }
        })
    }
    
    fileprivate func getVoiceDuration() {
        guard self.recordPath?.characters.count > 0 else {
            return
        }
        
        let url = URL(fileURLWithPath: self.recordPath!)
        do {
            let play = try AVAudioPlayer(contentsOf: url)
            self.recordDuration = play.duration
        }catch {
            self.recordDuration = 0
        }
    }
}

//#MARK: <AVAudioRecorderDelegate>
extension AudioRecordManager: AVAudioRecorderDelegate {
    
}





//#MARK: - ---AudioPlayManager---
public typealias AudioPlayProgress = (Double) -> ()
public typealias AudioPlayComplete = () -> ()

open class AudioPlayManager: NSObject {
    fileprivate static let _defaultInstance: AudioPlayManager = AudioPlayManager()
    fileprivate override init() {
        #if os(iOS)
            UIDevice.current.isProximityMonitoringEnabled = false
        #endif
    }
    open class func defaultMgr() -> AudioPlayManager {
        return _defaultInstance
    }
    
    open var playingFilePath: String?
    
    /// Update meter
    open var playProgress: AudioPlayProgress?
    open var playComplete: AudioPlayComplete?
    
    fileprivate var player: AVAudioPlayer?
    fileprivate var timer: Timer?
    
    /// Return the voice duration
    open var duration: TimeInterval? {
        return player?.duration
    }
    
    /// If the voice is playing, return voice currentPlaying time
    open var currentTime: TimeInterval? {
        return player?.currentTime
    }
    
    /**
     If the voice is playing
     
     :returns: the playing state
     */
    open func isPlaying() -> Bool {
        return player?.isPlaying ?? false
    }
    
    /**
     Toggle the playing state
     :param: filePath file path
     */
    open func togglePlay() {
        guard playingFilePath?.characters.count > 0 else {
            return
        }
        
        toggleAudio(playingFilePath)
    }
    open func toggleAudio(_ filePath: String?) {
        guard filePath?.characters.count > 0 else {
            return
        }
        
        if filePath == playingFilePath && player?.isPlaying == true {
            player?.stop()
        }else {
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayback)
                try session.setActive(true)
            }catch {
                return
            }
            #endif
            
            _ = playAudio(filePath)
        }
    }
    
    open func playAtTime(_ time: TimeInterval) {
        guard time > 0 && time <= duration else {
            return
        }
        player?.play(atTime: time)
    }
    
    fileprivate func playAudio(_ filePath: String?) -> Bool {
        player?.stop()
        
        
        let url = URL(fileURLWithPath: filePath!)
        do {
            let play = try AVAudioPlayer(contentsOf: url)
            play.delegate = self
            play.play()
            self.player = play
            playingFilePath = filePath
            
            
            // Open timer
            timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(AudioPlayManager.updateMeters), userInfo: nil, repeats: true)
        }catch {
            DebugLog(error)
            return false
        }
        return true
    }
    
    open func pausePlayingAudio() {
        player?.pause()
        resetTimer()
    }
    
    open func stopAudio() {
        self.playingFilePath = nil
        if player?.isPlaying == true {
            player?.stop()
            resetTimer()
        }
    }
}


extension AudioPlayManager {
    func updateMeters() {
        guard player != nil else {
            return
        }
        
        DispatchQueue.global().async(execute: {
            self.player?.updateMeters()
            if self.player?.isPlaying == true {
                let progress = (self.currentTime ?? 0) / (self.duration ?? 0) * 1.0
                DispatchQueue.main.async(execute: {
                    self.playProgress?(progress)
                })
            }
        })
    }
    
    fileprivate func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
}


//#MARK: <AVAudioPlayerDelegate>
extension AudioPlayManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudio()
        playComplete?()
    }
}
