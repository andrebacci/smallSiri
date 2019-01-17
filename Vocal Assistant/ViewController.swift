//
//  ViewController.swift
//  Vocal Assistant
//
//  Created by Andrea Bacigalupo on 16/01/19.
//  Copyright © 2019 Andrea Bacigalupo. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {

    // private
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var speechResult = SFSpeechRecognitionResult()
    
    let commands:[String] = [
        "Prova"
    ]
    
    // objects
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                var alertTitle = ""
                var alertMessage = ""
                
                switch authStatus {
                case .authorized:
                    do {
                       try self.startRecord()
                    } catch {
                        alertTitle = "Recorder Error"
                        alertMessage = "There was a problem starting the speech recorder"
                    }
                    
                case .denied:
                    alertTitle = "Speech recognizer not allowed"
                    alertMessage = "You enable the recgnizer in Settings"
                    
                case .restricted, .notDetermined:
                    alertTitle = "Could not start the speech recognizer"
                    alertMessage = "Check your internect connection and try again"
                }
                
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func timerEnded() {
        // If the audio recording engine is running stop it and remove the SFSpeechRecognitionTask
        if audioEngine.isRunning {
            stopRecording()
            checkForActionPhrases()
        }
    }

    private func startRecord() throws {
        if !audioEngine.isRunning {
            let timer = Timer(timeInterval: 5.0, target: self, selector: #selector(ViewController.timerEnded), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .common)
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.record
                , mode: AVAudioSession.Mode.default
                , options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true
                , options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            
            recognitionRequest?.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: (recognitionRequest ?? nil)!) { result, error in
                var isFinal = false
                
                if let result = result {
                    isFinal = result.isFinal
                    
                    self.speechResult = result
                    self.textView.text = result.bestTranscription.formattedString
                }
            }
        }
    }
}

