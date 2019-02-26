//
//  PlayVC.swift
//  Pitch Perfect
//
//  Created by taralika on 2/25/19.
//  Copyright © 2019 at. All rights reserved.
//

import AVFoundation
import UIKit

class PlayVC: UIViewController {
    
    @IBOutlet weak var slowBtn: UIButton!
    @IBOutlet weak var fastBtn: UIButton!
    @IBOutlet weak var highPitchBtn: UIButton!
    @IBOutlet weak var lowPitchBtn: UIButton!
    @IBOutlet weak var echoBtn: UIButton!
    @IBOutlet weak var reverbBtn: UIButton!
    @IBOutlet weak var stopPlayBtn: UIButton!
    
    var audioURL: URL!
    var audioFile: AVAudioFile!
    let engine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaybackInProgress(false)
        do
        {
            audioFile = try AVAudioFile(forReading: audioURL as URL)
        }
        catch
        {
            showAlert("Audio Playback Error", message: String(describing: error))
        }
    }
    
    @IBAction func slowBtnPressed(_ sender: UIButton) {
        playAudio(rate: 0.5)
    }
    
    @IBAction func fastBtnPressed(_ sender: Any) {
        playAudio(rate: 2)
    }
    
    @IBAction func highPitchBtnPressed(_ sender: Any) {
        playAudio(pitch: 1000)
    }
    
    @IBAction func lowPitchBtnPressed(_ sender: Any) {
        playAudio(pitch: -1000)
    }
    
    @IBAction func echoBtnPressed(_ sender: Any) {
        playAudio(echo: true)
    }
    
    @IBAction func reverbBtnPressed(_ sender: Any) {
        playAudio(reverb: true)
    }
    
    @IBAction func stopPlayBtnPressed(_ sender: Any) {
        stopPlayback()
    }
    
    
    func playAudio(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false)
    {
        let audioPlayer = AVAudioPlayerNode()
        engine.attach(audioPlayer)
        
        let ratePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            ratePitchNode.pitch = pitch
        }
        if let rate = rate {
            ratePitchNode.rate = rate
        }
        engine.attach(ratePitchNode)
        
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        engine.attach(reverbNode)
        
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        engine.attach(echoNode)
        
        engine.connect(audioPlayer, to: ratePitchNode, format: nil)
        
        if echo
        {
            engine.connect(ratePitchNode, to: echoNode, format: nil)
            engine.connect(echoNode, to: engine.outputNode, format: nil)
        }
        else if reverb
        {
            engine.connect(ratePitchNode, to: reverbNode, format: nil)
            engine.connect(reverbNode, to: engine.outputNode, format: nil)
        }
        else
        {
            engine.connect(ratePitchNode, to: engine.outputNode, format: nil)
        }
        
        audioPlayer.stop()
        setPlaybackInProgress(true)
        audioPlayer.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack, completionHandler: handleAudioPlaybackDone)
        
        do
        {
            try engine.start()
            audioPlayer.play()
        }
        catch
        {
            setPlaybackInProgress(false)
            showAlert("Audio Playback Error", message: String(describing: error))
        }
    }
    
    func handleAudioPlaybackDone(completionType: AVAudioPlayerNodeCompletionCallbackType)
    {
        DispatchQueue.main.async
        {
            self.stopPlayback()
        }
    }
    
    func stopPlayback()
    {
        self.engine.stop()
        self.engine.reset()
        self.setPlaybackInProgress(false)
    }
    
    func setPlaybackInProgress(_ isInProgress: Bool)
    {
        slowBtn.isEnabled = !isInProgress
        fastBtn.isEnabled = !isInProgress
        highPitchBtn.isEnabled = !isInProgress
        lowPitchBtn.isEnabled = !isInProgress
        echoBtn.isEnabled = !isInProgress
        reverbBtn.isEnabled = !isInProgress
        stopPlayBtn.isEnabled = isInProgress
    }
    
    func showAlert(_ title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
