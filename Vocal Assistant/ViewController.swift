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

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    // objects
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    
    // private
    var audioPlayer: AVAudioPlayer!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "it-IT"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    private let synth = AVSpeechSynthesizer()
    
    var utterance = AVSpeechUtterance()
    
    var isTrenitalia = false
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        speechRecognizer?.delegate = self
    }
    
    func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization {authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                print("Authorized")
                
                /* if let path = Bundle.main.url(forResource: "test", withExtension:"m4a") {
                    do {
                        let sound = try AVAudioPlayer(contentsOf: path)
                        self.audioPlayer = sound
                        sound.play()
                    } catch {
                        print("Error!")
                    } */
                    
                    /* let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: path)
                    recognizer?.recognitionTask(with: request) {(result, error) in
                        if let error = error {
                            print("There was an error: \(error)")
                        } else {
                            print(result?.bestTranscription.formattedString)
                        }
                    } */
            }
        }
    }
    
    // action
    @IBAction func recordBtnPress(_ sender: Any) {
        // request to use speech
        requestSpeechAuth()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("AudioSession properties weren't set because of an error.")
        }
        
        print("Start recording...")
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        let recognitionRequest = self.recognitionRequest
        recognitionRequest?.shouldReportPartialResults = true
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {(buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error")
        }
        
        textView.text = "Say something, I'm listening!"
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: {(result, error) in
            var isFinal = false
            if result != nil {                
                let speechedText = result?.bestTranscription.formattedString
                if speechedText != nil {
                    self.audioEngine.stop()
                    
                    //self.recognitionRequest?.endAudio()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                }
                
                // Write on textView
                self.textView.text = speechedText
                
                let words = speechedText?.components(separatedBy: " ")
                if (words?.count)! > 0 {
                    //self.stopRecording()
                }
                
                if words?.count == 1 {
                    let command = words?[0]
                    
                    if command?.lowercased() == "trenitalia" {
                        self.isTrenitalia = true
                        self.speak("Stazione di partenza del treno")
                        //self.startRecording()
                    } else {
                        
                    }
                } else {
                    if self.isTrenitalia {
                        self.manageTrenitalia(words!)
                    } else {
                        
                    }
                }
                
                /* for word in words! {
                    if word.contains("Stato del treno") {
                        print("Trenitalia")
                    }
                } */
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
    }
    
    func stopRecording() {
        self.recognitionRequest?.endAudio()
        self.audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            
        }
    }
    
    func manageTrenitalia(_ words: [String]) {
        print("Start manageTrenitalia...")
        
        for word in words {
            print(word)
        }
            
    }
    
    func speak(_ text: String) {
        print("Speak: " + text)
        
        utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        synth.speak(utterance)
    }
}

