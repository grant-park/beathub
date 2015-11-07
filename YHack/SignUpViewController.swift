//
//  SignUpViewController.swift
//  YHack
//
//  Created by Grant Hyun Park on 11/7/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @IBAction func signUpPressed(sender: AnyObject) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        
        if (username!.characters.count < 4 || password!.characters.count < 5) {
            
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater then 4 and Password must be greater then 5", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
        }else if (email!.characters.count < 8){
            
            let alert = UIAlertView(title: "Invalid", message: "Please enter a valid password.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
            
        }else {
            
            
            
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = email
            
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                if ((error) != nil) {
                    
                    
                    
                    let alert = UIAlertView(title: "Error", message: "\(error!.localizedDescription)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                }else {
                    
                    PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                        
                        
                        if ((user) != nil) {
                            
                            let loginStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let main: UIViewController = loginStoryboard.instantiateViewControllerWithIdentifier("RecorderViewController")
                            self.presentViewController(main, animated: false, completion: {
                                let alert = UIAlertView(title: "Success", message: "You've signed up and are logged in!", delegate: self, cancelButtonTitle: "OK")
                                alert.show()
                            })
                            //reload view after this

                        }else {
                            
                            
                                let alert = UIAlertView(title: "Error", message: "\(error!.localizedDescription)", delegate: self, cancelButtonTitle: "OK")
                                alert.show()
                            
                            
                        }
                        
                    })
                    
                    
                }
                
            })
            
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.view.addGestureRecognizer(recognizer)
        
        self.emailField.keyboardType = UIKeyboardType.EmailAddress
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        
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
