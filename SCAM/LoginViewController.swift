//
//  LoginViewController.swift
//  SCAM
//
//  Created by Charles Leon on 2/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//
import Parse
import SCLAlertView

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func logIn(_ sender: Any) {
        dismissKeyboard()
        if (emailField.text == "" || passwordField.text == nil) {
            emailField.shake()
        }
        if (passwordField.text == "" || passwordField.text == nil) {
            passwordField.shake()
            return
        }
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let waitingAlert = SCLAlertView(appearance: appearance)
        let responder = waitingAlert.showWait("Please Wait", subTitle: "We're trying to log you in.", closeButtonTitle: nil, duration: 0, colorStyle: 0x1461ab, colorTextButton: 0x1461ab, circleIconImage: nil, animationStyle: .topToBottom)
        PFUser.logInWithUsername(inBackground: emailField.text!.lowercased(), password: passwordField.text!) { (user: PFUser?, error: Error?) in
            responder.close()
            if (error == nil) {
                let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavigationController")
                self.present(dashboard!, animated: true, completion: nil)
            } else {
                SCLAlertView().showError("Oops", subTitle: (error?.localizedDescription)!)
            }
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
