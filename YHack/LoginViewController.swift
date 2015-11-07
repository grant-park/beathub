//
//  LoginViewController.swift
//  YHack
//
//  Created by Grant Hyun Park on 11/7/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!

    @IBAction func loginAction(sender: AnyObject) {
        let username = self.loginField.text
        let password = self.passwordField.text
        
        if ((username!.characters.count) < 4 || (password!.characters.count) < 5) {
            
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 4 and Password must be greater then 5", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        }else {
        
            
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                
                if ((user) != nil) {
                    
                    let loginStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let main: UIViewController = loginStoryboard.instantiateViewControllerWithIdentifier("RecorderViewController")
                    self.presentViewController(main, animated: false, completion: {
                        let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    })
                    
                    
                    
                    
                }else {
                    
                    

                        let alert = UIAlertView(title: "Error", message: "\(error!.localizedDescription)", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
 
                    
                }
                
            })
            
        }
    }
    
    @IBAction func fbPressed(sender: AnyObject) {
        let permissions = ["email"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let main: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RecorderViewController")
                    
                
                    self.presentViewController(main, animated: false, completion: { () -> Void in
                        let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    })
                } else {
                    print("User logged in through Facebook!")
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let main: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RecorderViewController")
                    self.presentViewController(main, animated: false, completion: { () -> Void in
                        let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                        
                        alert.show()
                    })
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.view.addGestureRecognizer(recognizer)
        
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
