//
//  NewsfeedViewController.swift
//  YHack
//
//  Created by Grant Hyun Park on 11/8/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class NewsfeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let reuseIdentifier = "newsCell"
    var posts: [PFObject] = []
    @IBAction func cancelled(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var newsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let postQuery = PFQuery(className: "Audio")
        postQuery.limit = 10
        postQuery.findObjectsInBackgroundWithBlock { (theArray, error) -> Void in
            self.posts = (theArray as [PFObject]!)!
        }

    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("bob")
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NewsCell
        
        let postings: PFObject = posts[indexPath.row]
        cell.newsLabel.text = postings["name"] as? String
        let theSound: PFFile = postings["audio"] as! PFFile
        
        theSound.getDataInBackgroundWithBlock { (soundData: NSData?, error: NSError?) -> Void in
                if error != nil {
                    print("error caching or downloading image")
                    return
                }
            do {let player = try AVAudioPlayer(data: soundData!);player.delegate=self as? AVAudioPlayerDelegate;cell.sound = player} catch {print("soundData pls")}
            }
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewsCell
        cell.sound.play()
    }
    
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

}
