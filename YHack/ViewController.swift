//
//  ViewController.swift
//  YHack
//
//  Created by Grant Hyun Park on 11/6/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?

    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.enabled = false
        stopButton.enabled = false
    
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let soundFileURL = documentsURL.URLByAppendingPathComponent("sound.caf")
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0 ]
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("error with audioSessoin")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings as! [String : AnyObject])
        } catch {
            print("error with audioRecorder")
        }
        
        audioRecorder?.prepareToRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        if audioRecorder?.recording == false {
            playButton.enabled = false
            stopButton.enabled = true
            audioRecorder?.record()
        }
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
        stopButton.enabled = false
        playButton.enabled = true
        recordButton.enabled = true
        
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch {
                print("audioSession not working")
            }
            print("stopped recording")
        } else {
            audioPlayer?.stop()
            print("stopped playing")
        }
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        if audioRecorder?.recording == false {
            stopButton.enabled = true
            recordButton.enabled = false
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: (audioRecorder?.url)!)
            } catch {
                print("audioPlayer error")
            }
            
            audioPlayer?.delegate = self
            
            audioPlayer?.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.enabled = true
        stopButton.enabled = false
        print("finished playing")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("yay")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Audio Record Encode Error")
    }


}


