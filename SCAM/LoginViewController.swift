//
//  LoginViewController.swift
//  SCAM
//
//  Created by Charles Leon on 2/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signIn(_ sender: Any) {
        if (emailField.text != nil && passwordField.text != nil) {
            PFUser.logInWithUsername(inBackground: emailField.text!, password: passwordField.text!) { (user: PFUser?, error: Error?) in
                if (error == nil) {
                    print("Success")
                } else {
                    print(error?.localizedDescription)
                }
            }
        } else {
            print("You're missing your email or password!")
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
