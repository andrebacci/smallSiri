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
    
    var isTrainService = false
    
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
        // If speech recognition is unavailable then do not attempt to start.
        guard speechRecognizer!.isAvailable else {
            return
        }
        
        label.text = "Recording..."
        
        // If we have a recognition task still running, so cancel it before starting a new one.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
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
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: {(result, error) in
            if let result = result {
                let command = result.bestTranscription.formattedString
                
                if command.lowercased().hasSuffix("stop") {
                    if command.lowercased().hasPrefix("stato del treno") {
                        self.trainServiceManager(command)
                    }
                }
            }
            
            if result?.isFinal ?? (error != nil) {
                inputNode.removeTap(onBus: 0)
                self.stopRecording()
            }
        })
        
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
    }
    
    func stopRecording() {
        /* self.recognitionRequest?.endAudio()
        self.audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil */
        
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        
        label.text = "Stopped recording"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            
        }
    }
    
    func speak(_ text: String) {
        print("Speak: " + text)
        
        utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        synth.speak(utterance)
    }
    
    func trainServiceManager(_ command: String) {
        var numberTrain = 0
        var station = "S00228"
        
        print("Start manageTrenitalia...")
        print("Command:", command)
        
        let strArray = command.components(separatedBy: " ")
        for str in strArray {
            if str.lowercased() == "treno" {
                let index: Int = strArray.index(of: str)!
                if Int(strArray[index + 1]) != nil {
                    numberTrain = Int(strArray[index + 1])!
                    if numberTrain != 0 {
                        break
                    }
                }
            }
        }
        
        var url = "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/andamentoTreno/"
        url += station + "/" + String(numberTrain)
        
        postUrl(url)
    }
    
    func postUrl(_ urlString: String) {
        let url = URL(string:urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            
            let str = String(data: data!, encoding: .utf8)
            print(str)
            
            }.resume()
    }
}

