//
//  StudioViewController.swift
//  YHack
//
//  Created by Grant Hyun Park on 11/7/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit
import AVFoundation
import Parse


class StudioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let reuseIdentifier = "customCell"
    
    @IBOutlet weak var leButton: UIButton!
    
    @IBAction func leButtonPressed(sender: AnyObject) {
        if (leButton.titleLabel?.text == "Pick First File") {
            leMerger1 = leSelection
            leButton.setTitle("Pick Second File", forState: .Normal)
        } else if (leButton.titleLabel?.text == "Pick Second File") {
            leMerger2 = leSelection
            leButton.setTitle("Save", forState: .Normal)
        } else if (leButton.titleLabel?.text == "Save") {
            //Parse upload and local save
            merge(leMerger1, audio2: leMerger2)
            leButton.setTitle("Pick First File", forState: .Normal)
        }
    }
    
    
    var recordings = [NSURL]()
    var player:AVAudioPlayer!
    
    var leMerger1: NSURL!
    var leMerger2: NSURL!
    
    var leSelection: NSURL!
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var tableView: UITableView!

    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        leButton.setTitle("Pick First File", forState: .Normal)
        print("view did load)")
        
        listRecordings()
        
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        recognizer.minimumPressDuration = 0.5 //seconds
        recognizer.delegate = self as? UIGestureRecognizerDelegate
        recognizer.delaysTouchesBegan = true
        self.tableView?.addGestureRecognizer(recognizer)
        
        let doubleTap = UITapGestureRecognizer(target:self, action:"doubleTap:")
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.delaysTouchesBegan = true
        self.tableView?.addGestureRecognizer(doubleTap)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("lolololol")
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.recordings.count)
        print("hello??")
        return self.recordings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomTableViewCell
        
        cell.label.text = recordings[indexPath.row].lastPathComponent
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected \(recordings[indexPath.row].lastPathComponent)")
        
        //var cell = collectionView.cellForItemAtIndexPath(indexPath)
        play(recordings[indexPath.row])
    }

    
    func play(url:NSURL) {
        print("playing \(url)")
        self.leSelection = url
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    
    func listRecordings() {
        
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        do {
            let urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            self.recordings = urls.filter( { (name: NSURL) -> Bool in
                return name.lastPathComponent!.hasSuffix("m4a")
            })
            
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("something went wrong listing recordings")
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getCacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        return paths[0]
    }
    
    func doubleTap(rec:UITapGestureRecognizer) {
        if rec.state != .Ended {
            return
        }
        
        let p = rec.locationInView(self.tableView)
        if let indexPath = self.tableView?.indexPathForRowAtPoint(p) {
            askToRename(indexPath.row)
        }
        
    }
    
    func longPress(rec:UILongPressGestureRecognizer) {
        if rec.state != .Ended {
            return
        }
        let p = rec.locationInView(self.tableView)
        if let indexPath = self.tableView?.indexPathForRowAtPoint(p) {
            askToDelete(indexPath.row)
        }
        
    }
    
    func askToDelete(row:Int) {
        let alert = UIAlertController(title: "Delete",
            message: "Delete Recording \(recordings[row].lastPathComponent!)?",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {action in
            print("yes was tapped \(self.recordings[row])")
            self.deleteRecording(self.recordings[row])
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: {action in
            print("no was tapped")
        }))
        self.presentViewController(alert, animated:true, completion:nil)
    }
    
    func deleteRecording(url:NSURL) {
        
        print("removing file at \(url.absoluteString)")
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.removeItemAtURL(url)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("error deleting recording")
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.listRecordings()
            self.tableView?.reloadData()
        })
    }
    
    func renameRecording(from:NSURL, to:NSURL) {
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let toURL = documentsDirectory.URLByAppendingPathComponent(to.lastPathComponent!)
        
        print("renaming file \(from.absoluteString) to \(to) url \(toURL)")
        let fileManager = NSFileManager.defaultManager()
        fileManager.delegate = self
        do {
            try NSFileManager.defaultManager().moveItemAtURL(from, toURL: toURL)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("error renaming recording")
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.listRecordings()
            self.tableView?.reloadData()
        })
        
    }

    
    func askToRename(row:Int) {
        let recording = self.recordings[row]
        
        let alert = UIAlertController(title: "Rename",
            message: "Rename Recording \(recording.lastPathComponent!)?",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {[unowned alert] action in
            print("yes was tapped \(self.recordings[row])")
            if let textFields = alert.textFields{
                let tfa = textFields as [UITextField]
                let text = tfa[0].text
                let url = NSURL(fileURLWithPath: text!)
                self.renameRecording(recording, to: url)
            }
            }))
        alert.addAction(UIAlertAction(title: "No", style: .Default, handler: {action in
            print("no was tapped")
        }))
        alert.addTextFieldWithConfigurationHandler({textfield in
            textfield.placeholder = "Enter a filename"
            textfield.text = "\(recording.lastPathComponent!)"
        })
        self.presentViewController(alert, animated:true, completion:nil)
    }

    
    func merge(audio1: NSURL, audio2:  NSURL) {
        
        
        var error:NSError?
        
        let ok1 = false
        let ok2 = false
        
        
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        let composition = AVMutableComposition()
        let compositionAudioTrack1:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        let compositionAudioTrack2:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        //create new file to receive data
        let documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent("resultmerge.m4a")
        print(fileDestinationUrl)
        
        let file = "resultmerge.m4a"
        var dirs : [String] = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])!
        let dir = dirs[0] //documents directory
        let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
        var pathURLarray:Array = (NSURL(fileURLWithPath: "\(path)")).pathComponents!
        
        
        var pathURL:String = ""
        var final = ""
        var debut = ""
        
        for i in 1...(pathURLarray.count-1) {
            if i == pathURLarray.count-1 {
                final = ""
            } else {
                final = "/"
            }
            if i == 1 {
                debut = "/"
            } else {
                debut = ""
            }
            pathURL = debut + pathURL + (pathURLarray[i] ) + final
        }
        
        let checkValidation = NSFileManager.defaultManager()
        if checkValidation.fileExistsAtPath(pathURL) {
            print("file exist")
            do {var lol = try NSFileManager.defaultManager().removeItemAtURL(fileDestinationUrl)} catch {
                print("nsfilemanager pls")
            }
        } else {
            print("no file")
        }
        
        
        let url1 = audio1
        let url2 = audio2
        
        
        let avAsset1 = AVURLAsset(URL: url1, options: nil)
        let avAsset2 = AVURLAsset(URL: url2, options: nil)
        
        var tracks1 =  avAsset1.tracksWithMediaType(AVMediaTypeAudio)
        var tracks2 =  avAsset2.tracksWithMediaType(AVMediaTypeAudio)
        
        let assetTrack1:AVAssetTrack = tracks1[0]
        let assetTrack2:AVAssetTrack = tracks2[0]
        
        
        let duration1: CMTime = assetTrack1.timeRange.duration
        let duration2: CMTime = assetTrack2.timeRange.duration
        
        let timeRange1 = CMTimeRangeMake(kCMTimeZero, duration1)
        let timeRange2 = CMTimeRangeMake(duration1, duration2)
        do {
            var ok1 = try compositionAudioTrack1.insertTimeRange(timeRange1, ofTrack: assetTrack1, atTime: kCMTimeZero)
        } catch {
            print("error with ok1")
        }
        if ok1 {
            
            do { var ok2 = try compositionAudioTrack2.insertTimeRange(timeRange2, ofTrack: assetTrack2, atTime: duration1)} catch {
                print("ok2 didnt work")
            }
            
            if ok2 {
                print("success")
            }
        }
        
        //AVAssetExportPresetPassthrough => concatenation
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport!.outputFileType = AVFileTypeAppleM4A
        assetExport!.outputURL = fileDestinationUrl
        assetExport!.exportAsynchronouslyWithCompletionHandler({
            switch assetExport!.status{
            case  AVAssetExportSessionStatus.Failed:
                print("failed \(assetExport!.error)")
            case AVAssetExportSessionStatus.Cancelled:
                print("cancelled \(assetExport!.error)")
            default:
                print("complete")
                var audioPlayer = AVAudioPlayer()
                do{ try audioPlayer = AVAudioPlayer(contentsOfURL: fileDestinationUrl, fileTypeHint: nil) } catch {
                    print("audioplayer pls")
                }
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
            
        })
        
    }


}

extension StudioViewController: NSFileManagerDelegate {
    
    func fileManager(fileManager: NSFileManager, shouldMoveItemAtURL srcURL: NSURL, toURL dstURL: NSURL) -> Bool {
        
        print("should move \(srcURL) to \(dstURL)")
        return true
    }
    
}
