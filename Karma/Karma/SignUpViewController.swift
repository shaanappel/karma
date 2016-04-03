//
//  SignUpViewController.swift
//  Karma
//
//  Created by Shaan Appel on 4/2/16.
//  Copyright © 2016 MDB - Karma. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var takenAlert: UILabel!
    @IBOutlet weak var emailAlert: UILabel!
    @IBOutlet weak var sameEmail: UILabel!
    
    var duplicateUsers = []
    var duplicateEmails = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takenAlert.hidden = true
        emailAlert.hidden = true
        sameEmail.hidden = true
    }
    
    func displayEmptyFieldError() {
        let alert = UIAlertController(title: "halp", message: "Please fill in all fields", preferredStyle: .Alert)
        let okay = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
        })
        alert.addAction(okay)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    @IBAction func trySignUp(sender: AnyObject) {
        
        self.emailAlert.hidden = true
        self.takenAlert.hidden = true
        
        let user = PFUser()
        user.username = username.text
        user.password = password.text
        user.email = email.text
        user["firstName"] = firstName.text
        
        user["lastName"] = lastName.text
        user["audienceLim"] = 1
        
        var query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: self.username.text!)
        do {
            self.duplicateUsers = try query.findObjects()
        } catch {
            print("Weird error")
        }
        
        query = PFQuery(className: "_User")
        query.whereKey("email", equalTo: self.email.text!)
        do {
            self.duplicateEmails = try query.findObjects()
        } catch {
            print("Weird error")
        }
        
        print(self.duplicateUsers.count)
        print(self.duplicateEmails.count)

        
        if self.duplicateUsers.count > 0 {
            self.takenAlert.hidden = false
            self.duplicateUsers = []
        } else {
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if (self.username.text == "" || self.password.text == "" || self.email.text == "" || self.lastName.text == "" || self.firstName.text == "") {
                
                self.displayEmptyFieldError()
                
            } else {
                    if (success) {
                        self.performSegueWithIdentifier("toMain2", sender: self)
                    } else {
                        print("email error?")
                        self.emailAlert.hidden = false
                    }
                }
            }
        
        
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
