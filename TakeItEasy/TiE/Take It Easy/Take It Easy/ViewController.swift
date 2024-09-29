//
//  ContentView.swift
//  TiEApp
//
//  Created by Chhibber, Rishi on 1/23/23.
//

import SwiftUI
import UIKit
import Speech
import PartialFuzzyWuzzySwift
import AVFoundation
import SPConfetti

extension StringProtocol {
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
}

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var targetText: String = "Twinkle Twinkle Little Star\nHow I wonder what you are"
    private var targetWords = [[String]]()
    private var poemId = 0
    
    @IBOutlet weak var poemTitle: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var readPoem: UITextView!
    @IBOutlet weak var helpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer.delegate = self
        listenButton.isEnabled = false
        listenButton.setDynamicFontSize()

        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.listenButton.isEnabled = true
                case .denied:
                    self.listenButton.isEnabled = false
                    self.resultLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.listenButton.isEnabled = false
                    self.resultLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.listenButton.isEnabled = false
                    self.resultLabel.text = "Speech recognition not yet authorized"
                @unknown default:
                    fatalError("Unable to continue")
                }
            }
        }
        targetWords = targetText.components(separatedBy: "\n").map{ $0.components(separatedBy: " ") }
        self.resultLabel.text = ""
        self.poemTitle.text = poemTitles[poemId]
        self.poemTitle.isHidden = false
        self.helpLabel.isHidden = false
        self.readPoem.text = ""
    }

    private var poemTitles = [
        "Twinkle, twinkle\n--Jane Taylor",
        "The Mock Turtle's Song\n-- Lewis Carroll",
        "At the Zoo\n-- William Makepeace Thackeray",

        "Mary had a little lamb\n-- Sarah Josepha Hale",
        "Nature’s first green is gold\n-- Robert Frost",
        "From A Railway Carriage\n-— Robert Louis Stevenson",

        "The Swing\n-— Robert Louis Stevenson",
        "Bed In Summer\n-- Robert Louis Stevenson",
        "Who has seen the wind?\n-- Christina Rossetti",
    ]

    
    private var poems = [
        """
        Twinkle, twinkle, little star!
        How I wonder what you are,
        Up above the world so high,
        Like a diamond in the sky.
        When the blazing sun is gone,
        When he nothing shines upon,
        Then you show your little light,
        Twinkle, twinkle, all the night.
        """,//  — Jane Taylor
        """
        “Will you walk a little faster?” said a whiting to a snail.
        “There’s a porpoise close behind us, and he’s treading on my tail.
        See how eagerly the lobsters and the turtles all advance!
        They are waiting on the shingle—will you come and join the dance?
        Will you, won’t you, will you, won’t you, will you join the dance?
        Will you, won’t you, will you, won’t you, won’t you join the dance?
        """, // Lewis Carroll
        """
        First I saw the white bear, then I saw the black;
        Then I saw the camel with a hump upon his back;
        Then I saw the grey wolf, with mutton in his maw;
        Then I saw the wombat waddle in the straw;
        Then I saw the elephant a-waving of his trunk;
        Then I saw the monkeys—mercy, how unpleasantly they smelt!
        """,
        
        """
        Mary had a little lamb,
        Its fleece was white as snow,
        And every where that Mary went
        The lamb was sure to go;
        He followed her to school one day—
        That was against the rule,
        It made the children laugh and play,
        To see a lamb at school.
        """,
        """
        Nature’s first green is gold,
        Her hardest hue to hold.
        Her early leaf’s a flower;
        But only so an hour.
        Then leaf subsides to leaf.
        So Eden sank to grief,
        So dawn goes down to day.
        Nothing gold can stay.
        """,
        """
        Faster than fairies, faster than witches,
        Bridges and houses, hedges and ditches;
        And charging along like troops in a battle,
        All through the meadows the horses and cattle:
        All of the sights of the hill and the plain
        Fly as thick as driving rain;
        And ever again, in the wink of an eye,
        Painted stations whistle by
        """, //  — Robert Louis Stevenson
        """
        Everyone grumbled. The sky was grey.
        We had nothing to do and nothing to say.
        We were nearing the end of a dismal day,
        And there seemed to be nothing beyond,
        THEN
        Daddy fell into the pond!
        """, //  — Alfred Noyes
        
        """
        How do you like to go up in a swing,
        Up in the air so blue?
        Oh, I do think it the pleasantest thing
        Ever a child can do!
        """, //  — Robert Louis Stevenson
        """
        In winter I get up at night
        And dress by yellow candle-light.
        In summer, quite the other way,
        I have to go to bed by day.
        I have to go to bed and see
        The birds still hopping on the tree,
        Or hear the grown-up people's feet
        Still going past me in the street.
        And does it not seem hard to you,
        When all the sky is clear and blue,
        And I should like so much to play,
        To have to go to bed by day?
        """, // Robert Louis Stevenson
        """
        Who has seen the wind?
        Neither I nor you:
        But when the leaves hang trembling,
        The wind is passing through.
        Who has seen the wind?
        Neither you nor I:
        But when the trees bow down their heads,
        The wind is passing by.
        """ // Christina Rossetti
    ]
    
    //set the target word that the user needs to read
    func settargetText(poemId: Int) {
        if poemId >= poems.count {
            self.poemId = 0
        } else {
            self.poemId = poemId
        }
        targetText = poems[self.poemId]
    }

    //start listening
    @IBAction func listenButtonTapped(_ sender: UIButton) {
        print(String(listenButton.titleLabel?.text ?? ""))
        self.readPoem.text = ""

        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionTask?.cancel()
            recognitionRequest?.endAudio()
            listenButton.setTitle("Start Listening", for: .normal)
            dismiss(animated: true, completion: nil)
        } else {
            listenButton.setTitle("Stop Listening", for: .normal)
            self.poemTitle.text = ""
            self.poemTitle.isHidden = true
            self.helpLabel.isHidden = true
            startRecording()
        }
        //self.resultLabel.text = "Let's Go"
    }
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let accolade = ["Sweet!", "Good Job!", "Way To Go"]
        var accolade_index = 0

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        //recognitionRequest.requiresOnDeviceRecognition = true
        var curListenedWordIndex:Int = -1
        
        var lineIndex: Int = 0
        var wordIndex: Int = 0
        var tries: Int = 0
        var confidence = 0
        self.readPoem.text = self.targetWords[0][0]

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false
            var finished = false
            
            if let result = result {
                if result.bestTranscription.segments.count > curListenedWordIndex {
                    print(curListenedWordIndex)
                    if (result.bestTranscription.segments.count > curListenedWordIndex) {
                        curListenedWordIndex = result.bestTranscription.segments.count
                        let target = self?.targetWords[lineIndex][wordIndex].lowercased()
                        let spoken = result.bestTranscription.segments[curListenedWordIndex-1].substring.lowercased()

                        if (target == "\n") {
                            confidence = 100
                        } else if let target = target, target.count < 3 {
                            confidence = 100
                        } else {
                            confidence = String.fuzzPartialRatio(str1:spoken, str2:target ?? "")
                        }
                        print(spoken + " [" + (target ?? "-NONE-") + "]. Confidence:" + String(confidence))

                        if confidence > 50 {
                            print("OK")
                            self?.resultLabel.text = accolade[accolade_index]
                            accolade_index = (accolade_index+1) % accolade.count
                            wordIndex += 1
                            if self?.targetWords[lineIndex].count == wordIndex {
                                wordIndex = 0;
                                lineIndex += 1
                                self?.readPoem.text = (self?.readPoem.text)! + "\n"
                                if self?.targetWords.count == lineIndex {
                                    finished = true
                                }
                            }
                            if (!finished) {
                                self?.readPoem.text = (self?.readPoem.text)! + " " + (self?.targetWords[lineIndex][wordIndex])!
                                print("T { " +  (self?.targetWords[lineIndex][wordIndex] ?? "*)") + " }")
                            }
                        } else {
                            print("RETRY")
                            self?.resultLabel.text = "Keep Trying."
                            tries += 1
                            if (tries >= 5) {
                                self?.resultLabel.text = "Let's Go."
                                tries = 0
                                wordIndex += 1
                                if self?.targetWords[lineIndex].count == wordIndex {
                                    wordIndex = 0;
                                    lineIndex += 1
                                    self?.readPoem.text = (self?.readPoem.text)! + "\n"
                                    if self?.targetWords.count == lineIndex {
                                        finished = true
                                    }
                                }
                                if (!finished) {
                                    self?.readPoem.text = (self?.readPoem.text)! + " " + (self?.targetWords[lineIndex][wordIndex])!
                                }
                            }
                        }
                    }
                }
                isFinal = /*result.isFinal || */finished
            }
            
            if error != nil || isFinal {
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self?.recognitionTask?.cancel()
                self?.recognitionRequest?.endAudio()
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
                print("All Done")
                self?.resultLabel.text = "Yay!!!!"
                let buttonText = self?.listenButton.titleLabel?.text
                if (buttonText == "Stop Listening") {
                    SPConfetti.startAnimating(.centerWidthToDown, particles: [.triangle, .arc], duration: 2)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.dismiss(animated: true, completion: nil)
                    // code to remove your view
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
}
