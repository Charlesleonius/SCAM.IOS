//
//  RegistrationViewController.swift
//  SCAM
//
//  Created by Charles Leon on 2/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import SafariServices

class RegistrationViewController: UIViewController {

    @IBOutlet weak var termsOfService: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    
    private var validEmail = false
    private var validPassword = false
    private var validPasswordConfirmation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //Style terms of service to make it stand out
        let termsOfServiceText = "By signing up, you agree to our Terms of Service."
        let attributedString = NSMutableAttributedString(string: "By signing up, you agree to our Terms of Service.")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: self.navigationController?.view.backgroundColor ?? UIColor.blue , range: (termsOfServiceText as NSString).range(of: "Terms of Service."))
        termsOfService.attributedText = attributedString
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(self.showTermsAndCondition(_:)))
        termsOfService.isUserInteractionEnabled = true
        termsOfService.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func showTermsAndCondition(_ sender: Any) {
        let url = URL.init(string: "Https://scam16.herokuapp.com")
        let svc = SFSafariViewController(url: url!)
        self.present(svc, animated: true, completion: nil)
    }

    @IBAction func verifyEmail(_ sender: Any) {
        //[A-Z0-9a-z._%+-] allows any of the following characters. +\\. requires a period before continuing text. [A-Z0-9a-z._%+-] allows any of these characters. '+@sjsu.edu' requires text to end with @sjsu.edu
        let regex = "[A-Z0-9a-z._%+-]+\\.[A-Z0-9a-z._%+-]+@sjsu.edu"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        if (test.evaluate(with: emailField.text)) {
            emailField.layer.borderColor = self.navigationController?.view.backgroundColor?.cgColor ?? UIColor.blue.cgColor
            validEmail = true
        } else {
            emailField.layer.borderColor = UIColor.red.cgColor
            validEmail = false
        }
        if (emailField.text == "") {
            emailField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        }
    }
    
    @IBAction func verifyPassword(_ sender: Any) {
        //Reset confirmation field when new password is entered
        passwordConfirmationField.text = ""
        passwordConfirmationField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        //[a-zA-Z0-9!@#$%^&*.(+=._-] allows all the characters contained within the brackets while the {8,} creates an 8 character mininum with no maximum
        let test = NSPredicate(format:"SELF MATCHES %@", "[a-zA-Z0-9!@#$%^&*.(+=._-]{8,}")
        if(test.evaluate(with: passwordField.text)) {
            passwordField.layer.borderColor = self.navigationController?.view.backgroundColor?.cgColor ?? UIColor.blue.cgColor
            validPassword = true
        } else {
            passwordField.layer.borderColor = UIColor.red.cgColor
            validPassword = false
        }
        if (passwordField.text == "") {
            passwordField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        }
    }
    
    @IBAction func verifyPasswordConfirmation(_ sender: Any) {
        if (passwordConfirmationField.text == passwordField.text) {
            passwordConfirmationField.layer.borderColor = self.navigationController?.view.backgroundColor?.cgColor ?? UIColor.blue.cgColor
            validPasswordConfirmation = true
        } else {
            passwordConfirmationField.layer.borderColor = UIColor.red.cgColor
            validPasswordConfirmation = false
        }
        if (passwordConfirmationField.text == "") {
            passwordConfirmationField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        }
    }

    @IBAction func register(_ sender: Any) {
        if (validEmail && validPassword && validPasswordConfirmation) {
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let waitingAlert = SCLAlertView(appearance: appearance)
            let responder = waitingAlert.showWait("Please Wait", subTitle: "We're trying to get you signed up!", closeButtonTitle: nil, duration: 0, colorStyle: 0x1461ab, colorTextButton: 0x1461ab, circleIconImage: nil, animationStyle: .topToBottom)
            let firstLastDirty = emailField.text?.components(separatedBy: CharacterSet(charactersIn: ".@"))
            let firstname = firstLastDirty?[0]
            let lastname = firstLastDirty?[1]
            
            let newUser = PFUser()
            newUser.username = self.emailField.text
            newUser.email = self.emailField.text
            newUser.password = self.passwordField.text
            newUser["firstName"] = firstname!.capitalized
            newUser["lastName"] = lastname!.capitalized
            newUser["deviceID"] = UIDevice.current.identifierForVendor!.uuidString
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                if (error == nil) {
                    /** Will be used later **/
                    //                    if let deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String {
                    //                        PFCloud.callFunction(inBackground: "updateInstallation", withParameters: ["deviceToken": deviceToken.lowercased()])
                    //                    }
                    responder.close()
                    //Show next screen
                    let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "requiredProfileNavigationController")
                    self.present(dashboard!, animated: true, completion: nil)
                } else {
                    responder.close()
                    let errorAlert = SCLAlertView()
                    var errorMessage = "Something went wrong, try again later!"
                    switch error!._code {
                    case 203:
                        errorMessage = "This email is already is use, please try another."
                        break
                    case 202:
                        errorMessage = "This email is already in use, please try another."
                        break
                    case 881:
                        errorMessage = error?.localizedDescription ?? "Something went wrong, try again later!"
                    default:
                        break
                    }
                    errorAlert.showError("Oops", subTitle: errorMessage)
                }
            }
        } else {
            if (!validEmail) {
                emailField.shake()
            }
            if (!validPassword) {
                passwordField.shake()
            }
            if (!validPasswordConfirmation) {
                passwordConfirmationField.shake()
            }
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
