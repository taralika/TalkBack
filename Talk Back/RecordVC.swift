//
//  RecordVC.swift
//  Pitch Perfect
//
//  Created by taralika on 2/22/19.
//  Copyright © 2019 at. All rights reserved.
//

import AVFoundation
import UIKit

class RecordVC: UIViewController, AVAudioRecorderDelegate {
    
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var recordLbl: UILabel!
    @IBOutlet weak var recordStopBtn: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRecordingInProgress(false)
    }
    
    @IBAction func recordBtnPressed(_ sender: UIButton, forEvent event: UIEvent) {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .spokenAudio)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                        self.recordLbl.text = "Failed to get permission to record. Go to device settings to enable."
                    }
                }
            }
        } catch {
            self.recordLbl.text = "Failed to record."
        }
    }
    
    func startRecording()
    {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.record()
            setRecordingInProgress(true)
        } catch {
            recordLbl.text = "Failed to record."
            finishRecording()
        }
    }
    
    func finishRecording()
    {
        setRecordingInProgress(false)
        audioRecorder.stop()
        try! recordingSession.setActive(false)
    }
    
    @IBAction func recordStopBtnPressed(_ sender: UIButton, forEvent event: UIEvent) {
        finishRecording()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag
        {
            performSegue(withIdentifier: "recordingStopped", sender: audioRecorder.url)
        }
        else
        {
            recordLbl.text = "Failed to record."
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "recordingStopped"
        {
            let playVC = segue.destination as! PlayVC
            let audioURL = sender as! URL
            playVC.audioURL = audioURL
        }
    }
    
    func setRecordingInProgress(_ isInProgress: Bool)
    {
        recordBtn.isEnabled = !isInProgress
        recordStopBtn.isEnabled = isInProgress
        if isInProgress
        {
            recordLbl.text = "Recording in progress..."
        }
        else
        {
            recordLbl.text = "Tap to record"
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
